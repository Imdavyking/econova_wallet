// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
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
const _wavesMainnetChainId = 0x57; // 'W'
const _wavesTestnetChainId = 0x54; // 'T'
const _wavesAddressVersion = 0x01;

// WAVES asset ID — null (empty) means native WAVES token
// For the binary tx: absent assetId = 0x00 flag byte
const _wavesAssetId = null; // native WAVES

// ─── Crypto helpers ───────────────────────────────────────────────────────────

Uint8List _sha256waves(Uint8List data) =>
    Uint8List.fromList(crypto.sha256.convert(data).bytes);

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
  final bool isTestnet;
  const WavesDeriveArgs({
    required this.seedRoot,
    required this.isTestnet,
    required this.mnemonic,
  });
}

//  {
//     "id": "waves",
//     "name": "Waves",
//     "coinId": 5741564,
//     "symbol": "WAVES",
//     "decimals": 8,
//     "blockchain": "Waves",
//     "derivation": [
//       {
//         "path": "m/44'/5741564'/0'/0'/0'"
//       }
//     ],
//     "curve": "ed25519",
//     "publicKeyType": "curve25519",
//     "explorer": {
//       "url": "https://wavesexplorer.com",
//       "txPath": "/tx/",
//       "accountPath": "/address/"
//     },
//     "info": {
//       "url": "https://wavesplatform.com",
//       "source": "https://github.com/wavesplatform/Waves",
//       "rpc": "https://nodes.wavesnodes.com",
//       "documentation": "https://nodes.wavesnodes.com/api-docs/index.html"
//     }
//   }import 'package:pointycastle/export.dart' as pc;

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

  final chainId = args.isTestnet ? _wavesTestnetChainId : _wavesMainnetChainId;
  final address = _buildWavesAddress(curve25519PubBytes, chainId);

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
  required int amountWavelets, // amount in wavelets (1 WAVES = 1e8)
  required int feeWavelets, // fee in wavelets
  required int timestamp, // millis
  required Uint8List attachment, // 0..140 bytes
}) {
  final buf = <int>[];

  buf.add(0x04); // tx type: Transfer
  buf.add(0x02); // version 2
  buf.addAll(senderPubKey); // 32 bytes
  buf.add(0x00); // assetFlag: WAVES (no assetId)
  buf.add(0x00); // feeAssetFlag: WAVES
  buf.addAll(_beInt64(timestamp)); // 8 bytes
  buf.addAll(_beInt64(amountWavelets)); // 8 bytes
  buf.addAll(_beInt64(feeWavelets)); // 8 bytes
  buf.add(0x01); // recipient type: address
  buf.addAll(recipientAddr); // 26 bytes
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
  final bool isTestnet_;

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
    required this.isTestnet_,
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

  int get _chainId => isTestnet_ ? _wavesTestnetChainId : _wavesMainnetChainId;

  // ─── Key derivation ─────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'wavesCoinDetail_V5${isTestnet_}_${walletImportType.name}';
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
        isTestnet: isTestnet_,
        mnemonic: mnemonic,
      ),
    );
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
    final key = 'wavesBalance_${isTestnet_}_$address';
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

  @override
  Future<double> getTransactionFee(String amount, String to) async => 0.001;

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
    final privSeed = Uint8List.fromList(HEX.decode(keyData.privateKey!));
    final pubKey = Uint8List.fromList(HEX.decode(keyData.publicKey!));

    // Reconstruct ed25519 keypair (seed + pubkey = 64 bytes for ed25519_edwards)
    final keyPair = ed.newKeyFromSeed(privSeed); // returns 64-byte key

    final amountWavelets = amount.toBigIntDec(decimals()).toInt();
    const feeWavelets = 100000; // 0.001 WAVES minimum fee
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Decode recipient address from base58 → 26 raw bytes
    final recipientBytes = _b58Decode(to);
    if (recipientBytes.length != 26) throw Exception('Invalid WAVES address');

    // Attachment: memo encoded as UTF-8 (max 140 bytes)
    final attachment = memo != null
        ? Uint8List.fromList(utf8.encode(memo).take(140).toList())
        : Uint8List(0);

    // Build signable bytes
    final signableBytes = _buildWavesTransferBytes(
      senderPubKey: pubKey,
      recipientAddr: recipientBytes,
      amountWavelets: amountWavelets,
      feeWavelets: feeWavelets,
      timestamp: timestamp,
      attachment: attachment,
    );

    // Sign with Ed25519
    final signature = ed.sign(keyPair, signableBytes); // 64 bytes

    // Encode to base58 for JSON broadcast
    final pubKeyB58 = _b58Encode(pubKey);
    final sigB58 = _b58Encode(signature);
    final recipientB58 = to; // already in base58

    // Build JSON body for /transactions/broadcast
    final txJson = {
      'type': 4,
      'version': 2,
      'senderPublicKey': pubKeyB58,
      'assetId': null, // WAVES
      'feeAssetId': null, // WAVES fee
      'timestamp': timestamp,
      'amount': amountWavelets,
      'fee': feeWavelets,
      'recipient': recipientB58,
      'attachment': _b58Encode(attachment),
      'proofs': [sigB58],
    };

    final txJsonStr = jsonEncode(txJson);

    if (kDebugMode) print('WAVES tx JSON: $txJsonStr');

    final res = await http.post(
      Uri.parse('$nodeUrl/transactions/broadcast'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: txJsonStr,
    );

    if (res.statusCode ~/ 100 != 2) {
      final err = jsonDecode(res.body);
      throw Exception('WAVES broadcast failed: ${err['message'] ?? res.body}');
    }

    final result = jsonDecode(res.body) as Map<String, dynamic>;
    final txHash = result['id'] as String;

    return (txHash: txHash, txRaw: txJsonStr);
  }

  // ─── Address validation ──────────────────────────────────────────────────────
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
            'wrong chain (expected ${isTestnet_ ? 'T' : 'W'}, got ${String.fromCharCode(decoded[1])})');
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

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  bool requireMemo() => true;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'WavesCoin',
        'isTestnet': isTestnet_,
        'symbol': symbol,
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
            'https://testnet.wavesexplorer.com/tx/$blockExplorerPlaceholder',
        image: 'assets/waves.png',
        nodeUrl: 'https://nodes-testnet.wavesnodes.com',
        geckoID: 'waves',
        rampID: '',
        payScheme: 'waves',
        isTestnet_: true,
      ),
    ];
  }
  return [
    WavesCoin(
      name: 'Waves',
      symbol: 'WAVES',
      default_: 'WAVES',
      blockExplorer: 'https://wavesexplorer.com/tx/$blockExplorerPlaceholder',
      image: 'assets/waves.png',
      nodeUrl: 'https://nodes.wavesnodes.com',
      geckoID: 'waves',
      rampID: '',
      payScheme: 'waves',
      isTestnet_: false,
    ),
  ];
}
