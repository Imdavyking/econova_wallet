// stacks_coin.dart
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart' as pc;
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:web3dart/crypto.dart' as w3;
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/pos_networks.dart';
import '../utils/c32check.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const int _microStxPerStx = 1000000;
const int _stacksDecimals = 6;
const String _hieroMainnet = 'https://api.hiro.so';
const String _hieroTestnet = 'https://api.testnet.hiro.so';

// Address version bytes
const int _versionMainnetP2PKH = 22; // SP…
const int _versionMainnetP2SH = 20; // SM…
const int _versionTestnetP2PKH = 26; // ST…
const int _versionTestnetP2SH = 21; // SN…

// Transaction wire format
const int _txVersionMainnet = 0x00;
const int _txVersionTestnet = 0x80;
const int _chainIdMainnet = 0x00000001;
const int _chainIdTestnet = 0x80000000;
const int _authTypeStandard = 0x04;
const int _hashModeP2PKH = 0x00;
const int _keyEncodingCompressed = 0x00;
const int _anchorModeAny = 0x03;
const int _postConditionModeAllow = 0x01;
const int _payloadTokenTransfer = 0x00;
const int _principalTypeStandard = 0x05;
const int _memoMaxBytes = 34;
const int _estimatedTxBytes = 180;

// secp256k1 prime p for y-coordinate recovery
final BigInt _secp256k1P = BigInt.parse(
  'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
  radix: 16,
);

// ─── Coin ─────────────────────────────────────────────────────────────────────

class StacksCoin extends Coin {
  final bool isTestnet;
  final NetworkType POSNetwork;
  final String derivationPath;
  final String blockExplorer;
  final String symbol;
  final String default_;
  final String image;
  final String name;
  final String geckoID;
  final String rampID;
  final String payScheme;

  StacksCoin({
    required this.isTestnet,
    required this.POSNetwork,
    required this.derivationPath,
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  // ─── Accessors ──────────────────────────────────────────────────────────────

  String get _api => isTestnet ? _hieroTestnet : _hieroMainnet;
  int get _addrVersion =>
      isTestnet ? _versionTestnetP2PKH : _versionMainnetP2PKH;
  int get _txVersion => isTestnet ? _txVersionTestnet : _txVersionMainnet;
  int get _chainId => isTestnet ? _chainIdTestnet : _chainIdMainnet;

  @override
  bool get isRpcWorking => true;
  @override
  bool get supportPrivateKey => true;
  @override
  bool requireMemo() => true;
  @override
  int decimals() => _stacksDecimals;
  @override
  String getName() => name;
  @override
  String getSymbol() => symbol;
  @override
  String getExplorer() => blockExplorer;
  @override
  String getDefault() => default_;
  @override
  String getImage() => image;
  @override
  String getGeckoId() => geckoID;
  @override
  String getRampID() => rampID;
  @override
  String getPayScheme() => payScheme;

  @override
  Map<String, dynamic> toJson() => {
        'isTestnet': isTestnet,
        'blockExplorer': blockExplorer,
        'symbol': symbol,
        'default': default_,
        'image': image,
        'name': name,
        'geckoID': geckoID,
        'rampID': rampID,
        'payScheme': payScheme,
        'derivationPath': derivationPath,
      };

  factory StacksCoin.fromJson(Map<String, dynamic> json) => StacksCoin(
        isTestnet: json['isTestnet'],
        blockExplorer: json['blockExplorer'],
        symbol: json['symbol'],
        default_: json['default'],
        image: json['image'],
        name: json['name'],
        geckoID: json['geckoID'],
        rampID: json['rampID'],
        payScheme: json['payScheme'],
        POSNetwork: json['isTestnet'] ? stacksTestnet : stacks,
        derivationPath: json['derivationPath'],
      );

  // ─── Address ────────────────────────────────────────────────────────────────

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  void validateAddress(String address) {
    final valid = isTestnet ? ['ST', 'SN'] : ['SP', 'SM'];
    if (!valid.any((p) => address.startsWith(p))) {
      throw Exception('Invalid $symbol address');
    }
    try {
      c32checkDecode(address.substring(1));
    } catch (_) {
      throw Exception('Invalid $symbol address checksum');
    }
  }

  // ─── Key derivation ─────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final cacheKey = 'stackscDetail$default_${walletImportType.name}';
    Map<String, dynamic> cached = {};

    if (pref.containsKey(cacheKey)) {
      cached = Map<String, dynamic>.from(jsonDecode(pref.get(cacheKey)));
      if (cached.containsKey(mnemonic)) {
        return AccountData.fromJson(cached[mnemonic]);
      }
    }

    final args = StacksDeriveArgs(
      seedRoot: seedPhraseRoot,
      derivationPath: derivationPath,
      POSNetwork: POSNetwork,
      addressVersion: _addrVersion,
    );

    final keys = await compute(calculateStacksKey, args);
    cached[mnemonic] = keys;
    await pref.put(cacheKey, jsonEncode(cached));

    return AccountData.fromJson(keys);
  }

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    final privBytes = txDataToUintList(privateKey);
    final pubBytes = _compressedPubKey(privBytes);
    final address =
        'S${c32checkEncode(_addrVersion, HEX.encode(_hash160(pubBytes)))}';
    return AccountData(
      address: address,
      privateKey: privateKey,
      publicKey: HEX.encode(pubBytes),
    );
  }

  @override
  Future<String?> resolveAddress(String address) async => address;

  // ─── Balance ────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final res = await http.get(Uri.parse('$_api/v2/accounts/$address?proof=0'));
    if (res.statusCode ~/ 100 != 2) throw Exception('STX balance fetch failed');
    final hexBal = jsonDecode(res.body)['balance'] as String;
    final micro = BigInt.parse(hexBal.replaceFirst('0x', ''), radix: 16);
    return micro / BigInt.from(_microStxPerStx);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = '${symbol}AddressBalance$address';
    final stored = pref.get(key) as double?;

    if (useCache) return stored ?? 0.0;
    try {
      final balance = await getUserBalance(address: address);
      await pref.put(key, balance);
      return balance;
    } catch (_) {
      return stored ?? 0.0;
    }
  }

  // ─── Fees ───────────────────────────────────────────────────────────────────

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final ratePerByte = await _fetchFeeRate();
    return (ratePerByte * _estimatedTxBytes) / _microStxPerStx;
  }

  Future<int> _fetchFeeRate() async {
    try {
      final res = await http.get(Uri.parse('$_api/v2/fees/transfer'));
      if (res.statusCode ~/ 100 == 2) {
        return int.parse(jsonDecode(res.body).toString());
      }
    } catch (_) {}
    return 10; // fallback: 10 µSTX / byte
  }

  Future<int> _fetchNonce(String address) async {
    final res = await http.get(Uri.parse('$_api/v2/accounts/$address?proof=0'));
    if (res.statusCode ~/ 100 != 2) throw Exception('STX nonce fetch failed');
    return jsonDecode(res.body)['nonce'] as int;
  }

  // ─── Transfer ───────────────────────────────────────────────────────────────

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(data);

    final privBytes = txDataToUintList(keyPair.privateKey!);
    final senderHash160 = _hash160(_compressedPubKey(privBytes));

    final nonce = await _fetchNonce(keyPair.address);
    final feeRate = await _fetchFeeRate();
    final fee = BigInt.from(feeRate * _estimatedTxBytes);
    final microStx =
        BigInt.from((double.parse(amount) * _microStxPerStx).toInt());

    final decoded = c32checkDecode(to.substring(1));
    final recipientVersion = decoded[0] as int;
    final recipientHash160 =
        Uint8List.fromList(HEX.decode(decoded[1] as String));

    final memoStr = (memo ?? '').trim();

    final txBytes = _buildSignedTx(
      privKey: privBytes,
      senderHash160: senderHash160,
      recipientVersion: recipientVersion,
      recipientHash160: recipientHash160,
      amount: microStx,
      nonce: BigInt.from(nonce),
      fee: fee,
      memo: memoStr,
    );

    final res = await http.post(
      Uri.parse('$_api/v2/transactions'),
      headers: {'Content-Type': 'application/octet-stream'},
      body: txBytes,
    );

    if (res.statusCode ~/ 100 != 2) {
      if (kDebugMode) print(res.body);
      throw Exception('STX broadcast failed: ${res.body}');
    }

    return jsonDecode(res.body) as String;
  }

  // ─── Transaction building + signing ─────────────────────────────────────────
  Uint8List _buildSignedTx({
    required Uint8List privKey,
    required Uint8List senderHash160,
    required int recipientVersion,
    required Uint8List recipientHash160,
    required BigInt amount,
    required BigInt nonce,
    required BigInt fee,
    required String memo,
  }) {
    // ✅ Zero nonce AND fee (not just signature) for the initial hash,
    //    matching makeSigHashPreSign() in @stacks/transactions
    final unsigned = _serialize(
      senderHash160: senderHash160,
      recipientVersion: recipientVersion,
      recipientHash160: recipientHash160,
      amount: amount,
      nonce: BigInt.zero, // ← was: nonce
      fee: BigInt.zero, // ← was: fee
      memo: memo,
      signature: Uint8List(65),
    );

    final initialHash = _sha512_256(unsigned);

    final preSignInput = (BytesBuilder()
          ..add(initialHash)
          ..addByte(_authTypeStandard)
          ..add(_u64BE(fee)) // actual fee folded in here
          ..add(_u64BE(nonce))) // actual nonce folded in here
        .toBytes();
    final presignHash = _sha512_256(preSignInput);

    final (sig, recoveryId) = _secp256k1Sign(privKey, presignHash);
    final sigBytes = Uint8List(65)
      ..[0] = recoveryId
      ..setRange(1, 33, _bigIntTo32Bytes(sig.r))
      ..setRange(33, 65, _bigIntTo32Bytes(sig.s));

    // Final serialization uses the REAL nonce and fee
    return _serialize(
      senderHash160: senderHash160,
      recipientVersion: recipientVersion,
      recipientHash160: recipientHash160,
      amount: amount,
      nonce: nonce, // ← real value
      fee: fee, // ← real value
      memo: memo,
      signature: sigBytes,
    );
  }

  /// Binary layout (SIP-005):
  ///   [1]  tx_version
  ///   [4]  chain_id
  ///   [1]  auth_type (0x04 = standard)
  ///   [1]  hash_mode (0x00 = P2PKH)
  ///   [20] signer hash160
  ///   [8]  nonce
  ///   [8]  fee_rate
  ///   [1]  key_encoding
  ///   [65] signature
  ///   [1]  anchor_mode
  ///   [1]  post_condition_mode
  ///   [4]  post_conditions count (0)
  ///   [1]  payload_type (0x00 = token transfer)
  ///   [1]  principal type (0x05 = standard)
  ///   [1]  recipient version
  ///   [20] recipient hash160
  ///   [8]  amount (µSTX)
  ///   [34] memo
  Uint8List _serialize({
    required Uint8List senderHash160,
    required int recipientVersion,
    required Uint8List recipientHash160,
    required BigInt amount,
    required BigInt nonce,
    required BigInt fee,
    required String memo,
    required Uint8List signature,
  }) {
    return (BytesBuilder()
          // Header
          ..addByte(_txVersion)
          ..add(_u32BE(_chainId))
          // Auth (standard single-sig P2PKH spending condition)
          ..addByte(_authTypeStandard)
          ..addByte(_hashModeP2PKH)
          ..add(senderHash160)
          ..add(_u64BE(nonce))
          ..add(_u64BE(fee))
          ..addByte(_keyEncodingCompressed)
          ..add(signature)
          // Anchor + post-conditions
          ..addByte(_anchorModeAny)
          ..addByte(_postConditionModeAllow)
          ..add(_u32BE(0)) // empty post-condition list
          // Payload: STX token transfer
          ..addByte(_payloadTokenTransfer)
          ..addByte(_principalTypeStandard)
          ..addByte(recipientVersion)
          ..add(recipientHash160)
          ..add(_u64BE(amount))
          ..add(_memoBytes(memo)))
        .toBytes();
  }

  // ─── Serialization helpers ───────────────────────────────────────────────────

  static Uint8List _memoBytes(String memo) {
    final src = utf8.encode(memo);
    final buf = Uint8List(_memoMaxBytes); // 34 bytes, zero-initialized
    final contentLen = src.length.clamp(0, _memoMaxBytes); // max 34
    buf.setRange(0, contentLen, src); // ← content at offset 0, no length prefix
    return buf;
  }

  static Uint8List _u32BE(int value) => Uint8List(4)
    ..[0] = (value >> 24) & 0xFF
    ..[1] = (value >> 16) & 0xFF
    ..[2] = (value >> 8) & 0xFF
    ..[3] = value & 0xFF;

  static Uint8List _u64BE(BigInt value) {
    final buf = Uint8List(8);
    var v = value.toUnsigned(64);
    for (int i = 7; i >= 0; i--) {
      buf[i] = (v & BigInt.from(0xFF)).toInt();
      v >>= 8;
    }
    return buf;
  }

  static Uint8List _bigIntTo32Bytes(BigInt v) =>
      Uint8List.fromList(HEX.decode(v.toRadixString(16).padLeft(64, '0')));

  // ─── Cryptographic helpers ───────────────────────────────────────────────────

  /// SHA-512/256 (FIPS 180-4 truncated variant — distinct IV from SHA-512)
  static Uint8List _sha512_256(Uint8List data) {
    final d = pc.SHA512tDigest(32)..update(data, 0, data.length);
    final out = Uint8List(32);
    d.doFinal(out, 0);
    return out;
  }

  /// SHA-256 via pointycastle digest — no HMac involved
  static Uint8List _sha256(Uint8List data) {
    final d = pc.SHA256Digest()..update(data, 0, data.length);
    final out = Uint8List(32);
    d.doFinal(out, 0);
    return out;
  }

  /// Manual HMAC-SHA256 — avoids pc.HMac entirely (which asserts digestSize*8 < 512)
  static Uint8List _hmacSha256(Uint8List key, Uint8List data) {
    const blockSize = 64;

    // Hash key down if longer than block size
    Uint8List k = key.length > blockSize ? _sha256(key) : key;

    // Zero-pad to block size
    if (k.length < blockSize) {
      final padded = Uint8List(blockSize);
      padded.setRange(0, k.length, k);
      k = padded;
    }

    final ipad = Uint8List(blockSize + data.length);
    final opad = Uint8List(blockSize + 32);

    for (int i = 0; i < blockSize; i++) {
      ipad[i] = k[i] ^ 0x36;
      opad[i] = k[i] ^ 0x5C;
    }
    ipad.setRange(blockSize, blockSize + data.length, data);

    final inner = _sha256(ipad);
    opad.setRange(blockSize, blockSize + 32, inner);

    return _sha256(opad);
  }

  /// RFC 6979 §2.3 — deterministic k using HMAC-SHA256
  static BigInt _rfc6979(Uint8List privKey, Uint8List hash, BigInt n) {
    var v = Uint8List(32)..fillRange(0, 32, 0x01);
    var k = Uint8List(32)..fillRange(0, 32, 0x00);

    k = _hmacSha256(k, Uint8List.fromList([...v, 0x00, ...privKey, ...hash]));
    v = _hmacSha256(k, v);
    k = _hmacSha256(k, Uint8List.fromList([...v, 0x01, ...privKey, ...hash]));
    v = _hmacSha256(k, v);

    while (true) {
      v = _hmacSha256(k, v);
      final candidate = BigInt.parse(HEX.encode(v), radix: 16);
      if (candidate >= BigInt.one && candidate < n) return candidate;
      // Retry
      k = _hmacSha256(k, Uint8List.fromList([...v, 0x00]));
      v = _hmacSha256(k, v);
    }
  }

  /// RIPEMD-160(SHA-256(pubKey))
  static Uint8List _hash160(Uint8List pubKey) {
    final shaOut = _sha256(pubKey);
    final rmd = pc.RIPEMD160Digest()..update(shaOut, 0, shaOut.length);
    final out = Uint8List(20);
    rmd.doFinal(out, 0);
    return out;
  }

  /// Compressed SEC-encoded public key from raw private key bytes
  static Uint8List _compressedPubKey(Uint8List privKey) {
    final params = pc.ECDomainParameters('secp256k1');
    final d = BigInt.parse(HEX.encode(privKey), radix: 16);
    return (params.G * d)!.getEncoded(true);
  }

  /// Deterministic secp256k1 ECDSA (RFC 6979) with low-S normalisation.
  /// Returns (ECSignature, recoveryId) where recoveryId ∈ {0, 1}.
  static (pc.ECSignature, int) _secp256k1Sign(
      Uint8List privKey, Uint8List hash) {
    final params = pc.ECDomainParameters('secp256k1');
    final n = params.n;
    final d = BigInt.parse(HEX.encode(privKey), radix: 16);

    // RFC6979 deterministic k — no pc.HMac used
    final k = _rfc6979(privKey, hash, n);

    final Renc = (params.G * k)!.getEncoded(false); // 04 || x(32) || y(32)
    final r = (BigInt.parse(HEX.encode(Renc.sublist(1, 33)), radix: 16)) % n;
    if (r == BigInt.zero) throw Exception('Invalid r (0)');

    final e = _hashToInt(hash, params);
    var s = (k.modInverse(n) * (e + d * r)) % n;
    if (s == BigInt.zero) throw Exception('Invalid s (0)');

    // Low-S normalisation
    if (s > (n >> 1)) s = n - s;

    final sig = pc.ECSignature(r, s);
    final pubKey = (params.G * d)!;
    final recoveryId = _computeRecoveryId(pubKey, sig, hash, params);

    return (sig, recoveryId);
  }

  /// Tries recovery IDs 0 and 1; returns whichever reconstructs our public key.
  /// Uses compressed-byte comparison instead of ECPoint.== (which compares
  /// object identity in pointycastle, not point equality).
  static int _computeRecoveryId(
    pc.ECPoint pubKey,
    pc.ECSignature sig,
    Uint8List hash,
    pc.ECDomainParameters params,
  ) {
    final expectedBytes = pubKey.getEncoded(true);
    for (int id = 0; id <= 1; id++) {
      final candidate = _recoverPubKey(id, sig, hash, params);
      if (candidate == null) continue;
      final candidateBytes = candidate.getEncoded(true);
      if (_bytesEqual(candidateBytes, expectedBytes)) return id;
    }
    throw Exception('Failed to compute secp256k1 recovery ID');
  }

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static pc.ECPoint? _recoverPubKey(
    int recId,
    pc.ECSignature sig,
    Uint8List hash,
    pc.ECDomainParameters params,
  ) {
    final n = params.n;
    final e = _hashToInt(hash, params);
    final x = sig.r + BigInt.from(recId ~/ 2) * n;

    if (x >= _secp256k1P) return null;

    final R = _decompressPoint(x, recId & 1 == 1, params);
    if (R == null) return null;

    final rInv = sig.r.modInverse(n);
    final u1 = ((-e % n) * rInv) % n;
    final u2 = (sig.s * rInv) % n;

    return (params.G * u1)! + (R * u2)!;
  }

  /// Truncate hash to the bit-length of the curve order, as per SEC1
  static BigInt _hashToInt(Uint8List hash, pc.ECDomainParameters params) {
    final orderBits = params.n.bitLength;
    final orderBytes = (orderBits + 7) ~/ 8;
    final len = hash.length < orderBytes ? hash.length : orderBytes;
    var z = BigInt.parse(HEX.encode(hash.sublist(0, len)), radix: 16);
    final excess = len * 8 - orderBits;
    if (excess > 0) z >>= excess;
    return z;
  }

  /// Lift x to a curve point on secp256k1 (y² = x³ + 7 mod p)
  static pc.ECPoint? _decompressPoint(
    BigInt x,
    bool oddY,
    pc.ECDomainParameters params,
  ) {
    final ySquared =
        (x.modPow(BigInt.from(3), _secp256k1P) + BigInt.from(7)) % _secp256k1P;
    final exp = (_secp256k1P + BigInt.one) >> 2;
    var y = ySquared.modPow(exp, _secp256k1P);
    if (y.isOdd != oddY) y = _secp256k1P - y;
    if ((y * y - ySquared) % _secp256k1P != BigInt.zero) return null;
    return params.curve.createPoint(x, y);
  }
}

// ─── Isolate args + worker ────────────────────────────────────────────────────

class StacksDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String derivationPath;
  final NetworkType POSNetwork;
  final int addressVersion;

  const StacksDeriveArgs({
    required this.seedRoot,
    required this.derivationPath,
    required this.POSNetwork,
    required this.addressVersion,
  });
}

/// Top-level function so compute() can spawn it in an isolate
Map<String, dynamic> calculateStacksKey(StacksDeriveArgs args) {
  final node = args.seedRoot.root.derivePath(args.derivationPath);

  final params = pc.ECDomainParameters('secp256k1');
  final d = BigInt.parse(HEX.encode(node.privateKey!), radix: 16);
  final pubKeyBytes = (params.G * d)!.getEncoded(true);

  // SHA-256 of pubkey
  final sha = pc.SHA256Digest()..update(pubKeyBytes, 0, pubKeyBytes.length);
  final shaOut = Uint8List(32);
  sha.doFinal(shaOut, 0);

  // RIPEMD-160 of SHA-256
  final rmd = pc.RIPEMD160Digest()..update(shaOut, 0, shaOut.length);
  final hash160 = Uint8List(20);
  rmd.doFinal(hash160, 0);

  return {
    'address': 'S${c32checkEncode(args.addressVersion, HEX.encode(hash160))}',
    'privateKey': '0x${HEX.encode(node.privateKey!)}',
    'publicKey': HEX.encode(pubKeyBytes),
  };
}

// ─── Factory ──────────────────────────────────────────────────────────────────

List<StacksCoin> getStacksBlockchains() {
  if (enableTestNet) {
    return [
      StacksCoin(
        name: 'Stacks(Test)',
        symbol: 'STX',
        default_: 'STX',
        isTestnet: true,
        blockExplorer:
            'https://explorer.hiro.so/txid/$blockExplorerPlaceholder?chain=testnet',
        image: 'assets/stacks.png',
        POSNetwork: stacksTestnet,
        derivationPath: "m/44'/5757'/0'/0/0",
        geckoID: 'blockstack',
        rampID: '',
        payScheme: 'stacks',
      ),
    ];
  }

  return [
    StacksCoin(
      name: 'Stacks',
      symbol: 'STX',
      default_: 'STX',
      isTestnet: false,
      blockExplorer:
          'https://explorer.hiro.so/txid/$blockExplorerPlaceholder?chain=mainnet',
      image: 'assets/stacks.png',
      POSNetwork: stacks,
      derivationPath: "m/44'/5757'/0'/0/0",
      geckoID: 'blockstack',
      rampID: '',
      payScheme: 'stacks',
    ),
  ];
}
