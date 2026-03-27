// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:bs58check/bs58check.dart' hide getAddress;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart' as pc;
import 'package:wallet_app/extensions/big_int_ext.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart' as crypto;
// Waves — ed25519 curve with Curve25519 public keys, BIP44 coin type 5741564
// Derivation : m/44'/5741564'/0'/0'/0'  (SLIP-0010 ed25519)
//
// Key facts:
//   - Private key : 32-byte seed, clamped for Curve25519
//   - Public key  : 32-byte Curve25519 (x-coordinate of Ed25519 point)
//   - Address     : Base58(version(1) + chainId(1) + keccak256(blake2b256(pk))[0:20] + checksum(4))
//   - Signing     : Ed25519 (standard), signature is 64 bytes
//   - Transfer tx : Waves transfer transaction v2, binary-serialized, Ed25519 signed
//
// The `ed25519_edwards` package (already in pubspec) provides Ed25519 sign/verify.

const _wavesDerivationPath = "m/44'/5741564'/0'/0'/0'";
const _wavesAddressVersion = 0x01;

// WAVES asset ID — null (empty) means native WAVES token
// For the binary tx: absent assetId = 0x00 flag byte
// native WAVES

// ─── Crypto helpers ───────────────────────────────────────────────────────────

Uint8List _keccak256waves(Uint8List data) {
  final d = pc.KeccakDigest(256);
  return d.process(data);
}

Uint8List _blake2b256waves(Uint8List data) {
  final d = pc.Blake2bDigest(digestSize: 32);
  return d.process(data);
}

/// Waves address hash: keccak256(blake2b256(pubKey)).sublist(0, 20)
Uint8List _wavesAddressHash(Uint8List pubKey) =>
    _keccak256waves(_blake2b256waves(pubKey)).sublist(0, 20);

// ─── Base58 (same alphabet as Bitcoin) ───────────────────────────────────────

const _b58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

String _b58Encode(Uint8List bytes) {
  if (bytes.isEmpty) return '';
  BigInt value = BigInt.parse(HEX.encode(bytes), radix: 16);
  var result = '';
  while (value > BigInt.zero) {
    final mod = value % BigInt.from(58);
    result = _b58[mod.toInt()] + result;
    value ~/= BigInt.from(58);
  }
  for (final b in bytes) {
    if (b != 0) break;
    result = '1$result';
  }
  return result;
}

Uint8List _b58Decode(String input) {
  BigInt value = BigInt.zero;
  for (final c in input.split('')) {
    final idx = _b58.indexOf(c);
    if (idx < 0) throw Exception('Invalid base58 char: $c');
    value = value * BigInt.from(58) + BigInt.from(idx);
  }
  final hex = value.toRadixString(16);
  final padded = hex.length.isOdd ? '0$hex' : hex;
  final bytes = Uint8List.fromList(HEX.decode(padded));
  final leading = input.split('').takeWhile((c) => c == '1').length;
  return Uint8List.fromList([...List.filled(leading, 0), ...bytes]);
}

/// Build 26-byte Waves address, base58-encoded
String _buildWavesAddress(Uint8List pubKey, int chainId) {
  final hash = _wavesAddressHash(pubKey);
  final withPrefix = Uint8List(22)
    ..[0] = _wavesAddressVersion
    ..[1] = chainId
    ..setRange(2, 22, hash);
  // checksum: keccak256(blake2b256(withPrefix)).sublist(0, 4)
  final checksum = _keccak256waves(_blake2b256waves(withPrefix)).sublist(0, 4);
  return _b58Encode(
    Uint8List.fromList([...withPrefix, ...checksum]),
  );
}

// ─── Isolate ──────────────────────────────────────────────────────────────────

class WavesDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String mnemonic;
  final int chainId;
  const WavesDeriveArgs({
    required this.seedRoot,
    required this.chainId,
    required this.mnemonic,
  });
}

/// Convert an Ed25519 public key (32 bytes) to Curve25519 (32 bytes)
/// Uses the birational equivalence: u = (1+y)/(1-y) mod p
Uint8List _ed25519PublicToCurve25519(Uint8List edPub) {
  // Ed25519 stores y with sign bit of x in the high bit of byte[31]
  final yBytes = Uint8List.fromList(edPub);
  yBytes[31] &= 0x7F; // clear sign bit to get raw y

  // p = 2^255 - 19
  final p = (BigInt.one << 255) - BigInt.from(19);

  // Decode y as little-endian
  BigInt y = BigInt.zero;
  for (int i = 31; i >= 0; i--) {
    y = (y << 8) | BigInt.from(yBytes[i]);
  }

  // u = (1 + y) / (1 - y) mod p
  final num = (BigInt.one + y) % p;
  final den = (BigInt.one - y + p) % p;
  final u = (num * den.modPow(p - BigInt.two, p)) % p;

  // Encode u as little-endian 32 bytes
  final uBytes = Uint8List(32);
  BigInt tmp = u;
  for (int i = 0; i < 32; i++) {
    uBytes[i] = (tmp & BigInt.from(0xFF)).toInt();
    tmp >>= 8;
  }
  return uBytes;
}

Future<Map<String, dynamic>> calculateWavesKey(WavesDeriveArgs args) async {
  // Step 1: SLIP-0010 ed25519 derivation from BIP39 seed
  final derived = await ED25519_HD_KEY.derivePath(
    _wavesDerivationPath, // "m/44'/5741564'/0'/0'/0'"
    args.seedRoot.seed, // raw 64-byte BIP39 seed
  );

  // Step 2: Ed25519 keypair from derived private scalar
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(derived.key);
  final edPublicKey = await keyPair.extractPublicKey();
  final edPubBytes = Uint8List.fromList(edPublicKey.bytes);

  // Step 3: Convert Ed25519 pubkey → Curve25519 pubkey for address
  final curve25519PubBytes = _ed25519PublicToCurve25519(edPubBytes);

  final chainId = args.chainId;
  final address = _buildWavesAddress(curve25519PubBytes, chainId);
  debugPrint(
    'base58: ${base58.encode(derived.key as Uint8List)}, address: $address pubkey: ${base58.encode(curve25519PubBytes)}',
  );
  return {
    'address': address,
    'privateKey': HEX.encode(derived.key),
    'publicKey': HEX.encode(curve25519PubBytes),
  };
}

// ─── Waves transfer tx v2 serialization ──────────────────────────────────────
//
// Transfer transaction v2 binary layout (without proofs):
//
//  0x04           : transaction type (4 = Transfer)
//  0x02           : version (2)
//  pubKey[32]     : sender public key
//  assetFlag(1)   : 0x00 = WAVES (no assetId)
//  feeAssetFlag(1): 0x00 = WAVES fee
//  timestamp(8)   : int64 big-endian millis
//  amount(8)      : int64 big-endian wavelets
//  fee(8)         : int64 big-endian wavelets  (min 100000 = 0.001 WAVES)
//  recipientType  : 0x01 = address
//  recipient[26]  : address bytes (decoded from base58)
//  attachLen(2)   : uint16 big-endian
//  attach[N]      : attachment bytes
//
// Proof: 0x01 (count) + 0x40 (64 = sig length) + sig[64]

Uint8List _beInt64(int value) {
  final b = ByteData(8);
  b.setInt64(0, value, Endian.big);
  return b.buffer.asUint8List();
}

Uint8List _beUInt16(int value) {
  final b = ByteData(2);
  b.setUint16(0, value, Endian.big);
  return b.buffer.asUint8List();
}

/// Build the signable bytes for a Waves transfer tx v2
Uint8List _buildWavesTransferBytes({
  required Uint8List senderPubKey, // 32 bytes
  required Uint8List recipientAddr, // 26 bytes (decoded)
  required int amountWavelets,
  required int feeWavelets,
  required int timestamp,
  required Uint8List attachment, // 0..140 bytes
}) {
  final buf = <int>[];

  buf.add(0x04); // tx type: Transfer
  buf.add(0x02); // version 2
  buf.addAll(senderPubKey); // 32 bytes
  buf.add(0x00); // assetFlag: WAVES
  buf.add(0x00); // feeAssetFlag: WAVES
  buf.addAll(_beInt64(timestamp)); // 8 bytes
  buf.addAll(_beInt64(amountWavelets)); // 8 bytes
  buf.addAll(_beInt64(feeWavelets)); // 8 bytes
  buf.addAll(recipientAddr); // 26 bytes — no 0x01 prefix
  buf.addAll(_beUInt16(attachment.length)); // 2 bytes
  buf.addAll(attachment); // attachment

  return Uint8List.fromList(buf);
}
// ─── WavesCoin ────────────────────────────────────────────────────────────────

class WavesCoin extends Coin {
  final String blockExplorer;
  final String nodeUrl;
  final String symbol;
  final String default_;
  final String image;
  final String name;
  final String geckoID;
  final String rampID;
  final String payScheme;
  final int chainId;

  WavesCoin({
    required this.blockExplorer,
    required this.nodeUrl,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    required this.chainId,
  });

  @override
  String getExplorer() => blockExplorer;
  @override
  String getDefault() => default_;
  @override
  String getImage() => image;
  @override
  String getName() => name;
  @override
  String getSymbol() => symbol;
  @override
  String getGeckoId() => geckoID;
  @override
  String getPayScheme() => payScheme;
  @override
  String getRampID() => rampID;
  @override
  int decimals() => 8;

  int get _chainId => chainId;

  // ─── Key derivation ─────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey =
        'wavesCoinDetail_V8338438434343334${chainId}_${walletImportType.name}';
    Map<String, dynamic> cache = {};
    if (pref.containsKey(saveKey)) {
      cache = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (cache.containsKey(mnemonic)) {
        return AccountData.fromJson(cache[mnemonic]);
      }
    }
    final result = await compute(
      calculateWavesKey,
      WavesDeriveArgs(
        seedRoot: seedPhraseRoot,
        chainId: chainId,
        mnemonic: mnemonic,
      ),
    );

    print('new');
    print(result);
    cache[mnemonic] = result;
    await pref.put(saveKey, jsonEncode(cache));
    return AccountData.fromJson(result);
  }

  // ─── Balance ────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final res = await http.get(
      Uri.parse('$nodeUrl/addresses/balance/$address'),
      headers: {'Accept': 'application/json'},
    );
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('WAVES balance fetch failed: ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    final wavelets = data['balance'] as int? ?? 0;
    return wavelets / 1e8;
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    if (chainId == 0x52) {
      try {
        final bal = await getUserBalance(address: address);
        if (bal < 100) {
          final genesis = await importFromWavesSeed(
            'waves private node seed with waves tokens',
          );
          await _transferWith(
            fromPrivKey: HEX.decode(genesis.privateKey!),
            fromPubKey: HEX.decode(genesis.publicKey!),
            to: address,
            amount: '1000', // send 1000 WAVES
          );
          debugPrint('[WAVES local] funded $address with 1000 WAVES');
        }
      } catch (e, sk) {
        debugPrint('[WAVES local] auto-fund failed: $e $sk');
      }
    }

    final key = 'wavesBalances_V1${chainId}_$address';
    final stored = pref.get(key) as double?;
    if (useCache) return stored ?? 0.0;
    try {
      final bal = await getUserBalance(address: address);
      await pref.put(key, bal);
      return bal;
    } catch (_) {
      return stored ?? 0.0;
    }
  }

  /// Sign and broadcast a transfer using explicit keys (not the active wallet).
  Future<({String txHash, String? txRaw})?> _transferWith({
    required List<int> fromPrivKey,
    required List<int> fromPubKey,
    required String to,
    required String amount,
    String? memo,
  }) async {
    final privSeed = Uint8List.fromList(fromPrivKey);
    final curve25519Pub = Uint8List.fromList(fromPubKey);
    final attachment = memo != null
        ? Uint8List.fromList(utf8.encode(memo).take(140).toList())
        : Uint8List(0);

    final amountWavelets = amount.toBigIntDec(decimals()).toInt();
    const feeWavelets = 100000;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final recipientBytes = _b58Decode(to);
    if (recipientBytes.length != 26) throw Exception('Invalid WAVES address');

    final signableBytes = _buildWavesTransferBytes(
      senderPubKey: curve25519Pub,
      recipientAddr: recipientBytes,
      amountWavelets: amountWavelets,
      feeWavelets: feeWavelets,
      timestamp: timestamp,
      attachment: attachment,
    );

    // ✅ use _wavesSign instead of ed25519.sign
    final sigBytes = await _wavesSign(privSeed, signableBytes);

    final txJson = jsonEncode({
      'type': 4,
      'version': 2,
      'senderPublicKey': _b58Encode(curve25519Pub),
      'assetId': null,
      'feeAssetId': null,
      'timestamp': timestamp,
      'amount': amountWavelets,
      'fee': feeWavelets,
      'recipient': to,
      'attachment': _b58Encode(attachment),
      'proofs': [_b58Encode(sigBytes)],
    });

    final res = await http.post(
      Uri.parse('$nodeUrl/transactions/broadcast'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: txJson,
    );

    if (res.statusCode ~/ 100 != 2) {
      final err = jsonDecode(res.body);
      throw Exception('WAVES broadcast failed: ${err['message'] ?? res.body}');
    }

    final result = jsonDecode(res.body) as Map<String, dynamic>;
    return (txHash: result['id'] as String, txRaw: txJson);
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async => 0.001;
  Future<Uint8List> _wavesSign(Uint8List privSeed, Uint8List message) async {
    final ed25519 = Ed25519();
    final keyPair = await ed25519.newKeyPairFromSeed(privSeed);

    // Get Ed25519 public key for the sign bit
    final edPub = await keyPair.extractPublicKey();
    final signBit = edPub.bytes[31] & 0x80;

    // Standard Ed25519 sign
    final sig = await ed25519.sign(message.toList(), keyPair: keyPair);
    final sigBytes = Uint8List.fromList(sig.bytes);

    // Patch byte 63 with sign bit from Ed25519 pubkey
    sigBytes[63] = (sigBytes[63] & 127) | signBit;

    return sigBytes;
  }
  // ─── Transfer ───────────────────────────────────────────────────────────────
  //
  // Full Waves transfer transaction v2:
  //   1. Build signable bytes
  //   2. Sign with Ed25519 using ed25519_edwards
  //   3. Attach proof
  //   4. POST to /transactions/broadcast as JSON

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final walletData = WalletService.getActiveKey(walletImportType)!.data;
    final keyData = await importData(walletData);

    return _transferWith(
      fromPrivKey: HEX.decode(keyData.privateKey!),
      fromPubKey: HEX.decode(keyData.publicKey!),
      to: to,
      amount: amount,
      memo: memo,
    );
  } // ─── Address validation ──────────────────────────────────────────────────────

  //
  // Decode from base58 → 26 bytes
  // Check: bytes[0] == 0x01 (version), bytes[1] == chainId
  // Verify checksum: last 4 bytes == keccak256(blake2b256(bytes[0..21]))[0:4]

  @override
  void validateAddress(String address) {
    try {
      final decoded = _b58Decode(address);
      if (decoded.length != 26) {
        throw Exception('bad length: ${decoded.length}');
      }
      if (decoded[0] != _wavesAddressVersion) {
        throw Exception('bad version byte');
      }
      if (decoded[1] != _chainId) {
        throw Exception(
            'wrong chain (expected $chainId, got ${String.fromCharCode(decoded[1])})');
      }
      final payload = decoded.sublist(0, 22);
      final checksum = decoded.sublist(22);
      final expected =
          _keccak256waves(_blake2b256waves(Uint8List.fromList(payload)))
              .sublist(0, 4);
      for (int i = 0; i < 4; i++) {
        if (checksum[i] != expected[i]) throw Exception('bad checksum');
      }
    } catch (e) {
      throw Exception('Invalid WAVES address: $e');
    }
  }

  /// Derive a Waves account from a native Waves seed string (not BIP39).
  /// Used for the private node genesis account and any seed imported via
  /// the Waves desktop/web client.
  Future<AccountData> importFromWavesSeed(String wavesSeed) async {
    final seedBytes = Uint8List.fromList(utf8.encode(wavesSeed));
    final nonce = Uint8List.fromList([0, 0, 0, 0]);

    // Step 1: keccak256(blake2b256(nonce + seed))  ← was wrong (sha256)
    final nonceAndSeed = Uint8List.fromList([...nonce, ...seedBytes]);
    final accountSeed = _keccak256waves(_blake2b256waves(nonceAndSeed));

    // Step 2: sha256(accountSeed) → raw private scalar
    var privKey = Uint8List.fromList(
      crypto.sha256.convert(accountSeed).bytes,
    );

    // Step 3: Curve25519 clamping
    privKey[0] &= 0xF8;
    privKey[31] &= 0x7F;
    privKey[31] |= 0x40;
    print('private test');
    print(base58.encode(privKey));

    // Step 4: Curve25519 public key
    final x25519 = X25519();
    final kp = await x25519.newKeyPairFromSeed(privKey);
    final pub = await kp.extractPublicKey();
    final curve25519Pub = Uint8List.fromList(pub.bytes);

    final address = _buildWavesAddress(curve25519Pub, chainId);

    return AccountData.fromJson({
      'address': address,
      'privateKey': HEX.encode(privKey),
      'publicKey': HEX.encode(curve25519Pub),
    });
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/transactions/', '/addresses/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  bool requireMemo() => true;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'WavesCoin',
        'symbol': symbol,
        'chainId': chainId,
        'blockExplorer': blockExplorer,
        'nodeUrl': nodeUrl,
        'name': name,
        'image': image,
        'geckoID': geckoID,
        'rampID': rampID,
        'payScheme': payScheme,
      };
}

// ─── Factory ──────────────────────────────────────────────────────────────────

List<WavesCoin> getWavesBlockChains() {
  if (enableTestNet) {
    return [
      WavesCoin(
        name: 'Waves (Testnet)',
        symbol: 'WAVES',
        default_: 'WAVES',
        blockExplorer:
            'https://wavesexplorer.com/transactions/$blockExplorerPlaceholder/?network=testnet',
        image: 'assets/waves.png',
        nodeUrl: 'https://nodes-testnet.wavesnodes.com',
        geckoID: 'waves',
        rampID: '',
        payScheme: 'waves',
        chainId: 0x54,
      ),
      WavesCoin(
        name: 'Waves (Stagenet)',
        symbol: 'WAVES',
        default_: 'WAVES',
        blockExplorer:
            'https://wavesexplorer.com/transactions/$blockExplorerPlaceholder/?network=stagenet',
        image: 'assets/waves.png',
        nodeUrl: 'https://nodes-stagenet.wavesnodes.com',
        geckoID: 'waves',
        rampID: '',
        payScheme: 'waves',
        chainId: 0x53,
      ),
// The private node comes with a pre-funded genesis account built in:

// Seed: waves private node seed with waves tokens
// Address: 3M4qwDomRabJKLZxuXhwfqLApQkU592nWxF
// Balance: 100,000,000 WAVES 🎉
      WavesCoin(
        name: 'Waves (Local)',
        symbol: 'WAVES',
        default_: 'WAVES',
        blockExplorer:
            'http://localhost:6869/transactions/info/$blockExplorerPlaceholder',
        image: 'assets/waves.png',
        nodeUrl: 'http://localhost:6869',
        geckoID: 'waves',
        rampID: '',
        payScheme: 'waves',
        chainId: 0x52, // 'R' = private network
      ),
    ];
  }
  return [
    WavesCoin(
      name: 'Waves',
      symbol: 'WAVES',
      default_: 'WAVES',
      blockExplorer:
          'https://wavesexplorer.com/transactions/$blockExplorerPlaceholder',
      image: 'assets/waves.png',
      nodeUrl: 'https://nodes.wavesnodes.com',
      geckoID: 'waves',
      rampID: '',
      payScheme: 'waves',
      chainId: 0x57,
    ),
  ];
}
