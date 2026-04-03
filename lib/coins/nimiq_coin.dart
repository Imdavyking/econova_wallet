// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto_pkg;
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import '../fetchers/nimiq_trx_fetcher.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import '../utils/wallet_transaction.dart';

const nimiqDecimals = 5; // 1 NIM = 100,000 Luna

// ── Network ───────────────────────────────────────────────────────────────────

enum NimiqNetwork {
  mainnet(24),
  testnet(5);

  const NimiqNetwork(this.id);
  final int id;
}

// ── Coin ──────────────────────────────────────────────────────────────────────

class NimiqCoin extends Coin {
  final String blockExplorer;
  final String symbol;
  final String default_;
  final String image;
  final String name;
  final String rpcUrl;
  final NimiqNetwork network;
  final String caipReference;

  NimiqCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.rpcUrl,
    required this.network,
    required this.caipReference,
  });

  // ── TransactionFetcher ───────────────────────────────────────────────────

  @override
  TransactionFetcher? get transactionFetcher => NimiqTransactionFetcher(
        rpcUrl: rpcUrl,
        symbol: symbol,
        explorerUrlTemplate: blockExplorer,
      );

  // ── Coin interface ───────────────────────────────────────────────────────

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
  int decimals() => nimiqDecimals;
  @override
  String getGeckoId() => 'nimiq-2';
  @override
  String getRampID() => '';
  @override
  String getPayScheme() => 'nimiq';
  @override
  String get caip2Namespace => 'nimiq';
  @override
  String get caip2Reference => caipReference;
  @override
  bool get supportBip39Seed => true;

  // ── Key derivation ───────────────────────────────────────────────────────

  @override
  Future<AccountData> fromBip39PhraseOrSeed({
    required String bip39PhraseOrSeedHex,
  }) =>
      Coin.fromBip39PhraseOrSeedCached(
        cacheKey: 'nimiqDetails${walletImportType.name}',
        bip39PhraseOrSeedHex: bip39PhraseOrSeedHex,
        derive: () => compute(
          calculateNimiqKey,
          NimiqDeriveArgs(seedRoot: seedPhraseRoot),
        ),
      );

  // ── Balance ──────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final data = await _rpc('getAccountByAddress', [address]);
    final balanceLuna = (data['balance'] as num? ?? 0).toInt();
    return balanceLuna / pow(10, nimiqDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final cacheKey = 'nimiqBalance$address$rpcUrl';
    final saved = (pref.get(cacheKey) as double?) ?? 0.0;
    if (useCache) return saved;
    try {
      final balance = await getUserBalance(address: address);
      await pref.put(cacheKey, balance);
      return balance;
    } catch (_) {
      return saved;
    }
  }

  // ── Transfer ─────────────────────────────────────────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final keyMap = await compute(
      calculateNimiqKey,
      NimiqDeriveArgs(seedRoot: seedPhraseRoot),
    );
    final privateKeyBytes =
        Uint8List.fromList(HEX.decode(keyMap['privateKey'] as String));
    final publicKeyBytes =
        Uint8List.fromList(HEX.decode(keyMap['publicKey'] as String));
    final senderAddress = keyMap['address'] as String;

    final luna = (double.parse(amount) * pow(10, nimiqDecimals)).round();
    const feeInLuna = 138; // minimal relay fee

    // Current block height for validity window
    final heightData = await _rpc('getBlockNumber', []);
    final currentHeight = (heightData as num).toInt();

    final senderBytes = NimiqAddress.decode(senderAddress);
    final recipientBytes = NimiqAddress.decode(to);

    final txBody = _NimiqTx.buildBody(
      sender: senderBytes,
      recipient: recipientBytes,
      valueLuna: luna,
      feeLuna: feeInLuna,
      validityStartHeight: currentHeight,
      networkId: network.id,
      memo: memo,
    );

    final signature = _nimiqSign(privateKeyBytes, txBody);

    final rawTx = _NimiqTx.appendProof(
      txBody: txBody,
      publicKey: publicKeyBytes,
      signature: signature,
    );

    final txHash =
        await _rpc('sendRawTransaction', [HEX.encode(rawTx)]) as String;
    return (txHash: txHash, txRaw: HEX.encode(rawTx));
  }

  // ── Misc ─────────────────────────────────────────────────────────────────

  @override
  void validateAddress(String address) => NimiqAddress.decode(address);

  @override
  Future<double> getTransactionFee(String amount, String to) async =>
      0.00138; // 138 Luna

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer.replaceFirst(
      '/transactions/$blockExplorerPlaceholder',
      '/address/$address',
    );
  }

  // ── Serialization ────────────────────────────────────────────────────────

  factory NimiqCoin.fromJson(Map<String, dynamic> json) => NimiqCoin(
        blockExplorer: json['blockExplorer'] as String,
        symbol: json['symbol'] as String,
        default_: json['default'] as String,
        image: json['image'] as String,
        name: json['name'] as String,
        rpcUrl: json['rpcUrl'] as String,
        network: NimiqNetwork.values.firstWhere(
          (n) => n.id == json['networkId'],
          orElse: () => NimiqNetwork.mainnet,
        ),
        caipReference: json['caipReference'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'blockExplorer': blockExplorer,
        'symbol': symbol,
        'default': default_,
        'image': image,
        'name': name,
        'rpcUrl': rpcUrl,
        'networkId': network.id,
        'caipReference': caipReference,
      };

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Calls the Nimiq JSON-RPC and returns `result.data`.
  Future<dynamic> _rpc(String method, List<dynamic> params) async {
    final response = await http
        .post(
          Uri.parse(rpcUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'method': method,
            'params': params,
          }),
        )
        .timeout(networkTimeOutDuration);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body.containsKey('error')) {
      final err = body['error'] as Map<String, dynamic>;
      throw Exception(err['message'] ?? 'Nimiq RPC error');
    }
    return (body['result'] as Map<String, dynamic>?)?['data'];
  }
}

// ── Registry ──────────────────────────────────────────────────────────────────

List<NimiqCoin> getNimiqBlockchains() {
  if (enableTestNet) {
    return [
      NimiqCoin(
        blockExplorer:
            'https://test.nimiqscan.io/transactions/$blockExplorerPlaceholder',
        symbol: 'NIM',
        name: 'Nimiq (Testnet)',
        default_: 'NIM',
        image: 'assets/nimiq.png',
        rpcUrl: 'https://rpc.nimiqwatch.com',
        network: NimiqNetwork.testnet,
        caipReference: 'testnet',
      ),
    ];
  }
  return [
    NimiqCoin(
      blockExplorer:
          'https://nimiqscan.io/transactions/$blockExplorerPlaceholder',
      symbol: 'NIM',
      name: 'Nimiq',
      default_: 'NIM',
      image: 'assets/nimiq.png',
      rpcUrl: 'https://rpc.nimiqwatch.com',
      network: NimiqNetwork.mainnet,
      caipReference: 'mainnet',
    ),
  ];
}

// ── Derive args ───────────────────────────────────────────────────────────────

class NimiqDeriveArgs {
  final SeedPhraseRoot seedRoot;
  const NimiqDeriveArgs({required this.seedRoot});
}

/// Top-level function — must stay top-level so [compute] can spawn it.
Future<Map<String, dynamic>> calculateNimiqKey(NimiqDeriveArgs args) async {
  // BIP-44 coin type 242 for Nimiq
  const path = "m/44'/242'/0'/0'/0'";
  final masterKey = await ED25519_HD_KEY.derivePath(path, args.seedRoot.seed);
  final seedBytes = Uint8List.fromList(masterKey.key);

  // Full Ed25519 key pair from the 32-byte seed
  final edPrivKey = ed25519.newKeyFromSeed(seedBytes);
  final publicKeyBytes = Uint8List.fromList(ed25519.public(edPrivKey).bytes);

  // Nimiq address: Blake2b-256(publicKey), first 20 bytes
  final blake2b = crypto_pkg.Blake2b(hashLengthInBytes: 32);
  final hashResult = await blake2b.hash(publicKeyBytes);
  final addressBytes = Uint8List.fromList(hashResult.bytes.sublist(0, 20));
  final address = NimiqAddress.encode(addressBytes);

  return {
    'address': address,
    'privateKey': HEX.encode(seedBytes),
    'publicKey': HEX.encode(publicKeyBytes),
  };
}

/// Synchronous Ed25519 sign — safe to call outside an isolate.
Uint8List _nimiqSign(Uint8List privateKeySeed, Uint8List message) {
  final edPrivKey = ed25519.newKeyFromSeed(privateKeySeed);
  // ed25519.sign() returns [64-byte signature ++ message]
  return Uint8List.fromList(
    ed25519.sign(edPrivKey, message).sublist(0, 64),
  );
}

// ── Nimiq address encoding / decoding ─────────────────────────────────────────

class NimiqAddress {
  NimiqAddress._();

  // Nimiq's Crockford-inspired base-32 alphabet (no I, O)
  static const _alphabet = '0123456789ABCDEFGHJKLMNPQRSTUVXY';

  /// Encodes 20 raw address bytes into Nimiq user-friendly format (36 chars).
  static String encode(List<int> addressBytes) {
    assert(addressBytes.length == 20, 'Nimiq address must be 20 bytes');
    final base32 = _toBase32(Uint8List.fromList(addressBytes));
    final check = (98 - _ibanMod97('NQ00$base32')).toString().padLeft(2, '0');
    return 'NQ$check$base32';
  }

  /// Decodes a Nimiq user-friendly address (with or without spaces) into 20
  /// raw bytes. Throws [FormatException] for invalid input.
  static Uint8List decode(String address) {
    final clean = address.replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (!clean.startsWith('NQ') || clean.length != 36) {
      throw FormatException(
          'Invalid Nimiq address (expected 36 chars): $address');
    }
    final checkDigits = clean.substring(2, 4);
    final base32 = clean.substring(4);
    if (_ibanMod97('NQ$checkDigits$base32') != 1) {
      throw FormatException('Invalid Nimiq address checksum: $address');
    }
    return _fromBase32(base32);
  }

  // ── Base-32 helpers (MSB-first, 5 bits per char) ──────────────────────

  static String _toBase32(Uint8List buf) {
    final sb = StringBuffer();
    for (int i = 0; i < 32; i++) {
      final bitPos = i * 5;
      final byteIdx = bitPos >> 3;
      final bitOffset = bitPos & 7;

      int value;
      if (bitOffset + 5 <= 8) {
        // All 5 bits inside one byte
        value = (buf[byteIdx] >> (3 - bitOffset)) & 0x1F;
      } else {
        // Split across two consecutive bytes
        final bitsFromFirst = 8 - bitOffset;
        final bitsFromSecond = 5 - bitsFromFirst;
        final firstPart =
            (buf[byteIdx] & ((1 << bitsFromFirst) - 1)) << bitsFromSecond;
        final secondPart = buf[byteIdx + 1] >> (8 - bitsFromSecond);
        value = firstPart | secondPart;
      }
      sb.write(_alphabet[value]);
    }
    return sb.toString();
  }

  static Uint8List _fromBase32(String base32) {
    if (base32.length != 32) {
      throw FormatException('Expected 32 base-32 chars, got ${base32.length}');
    }
    final buf = Uint8List(20);
    for (int i = 0; i < 32; i++) {
      final value = _alphabet.indexOf(base32[i]);
      if (value < 0) {
        throw FormatException('Invalid char in Nimiq address: ${base32[i]}');
      }
      final bitPos = i * 5;
      final byteIdx = bitPos >> 3;
      final bitOffset = bitPos & 7;

      if (bitOffset + 5 <= 8) {
        buf[byteIdx] |= value << (3 - bitOffset);
      } else {
        final bitsFromFirst = 8 - bitOffset;
        final bitsFromSecond = 5 - bitsFromFirst;
        buf[byteIdx] |= (value >> bitsFromSecond) & ((1 << bitsFromFirst) - 1);
        if (byteIdx + 1 < 20) {
          buf[byteIdx + 1] |=
              (value & ((1 << bitsFromSecond) - 1)) << (8 - bitsFromSecond);
        }
      }
    }
    return buf;
  }

  // ── IBAN mod-97 checksum ───────────────────────────────────────────────

  static int _ibanMod97(String str) {
    int rem = 0;
    for (final c in str.codeUnits) {
      if (c >= 0x30 && c <= 0x39) {
        // '0'–'9' → one decimal digit
        rem = (rem * 10 + (c - 0x30)) % 97;
      } else if (c >= 0x41 && c <= 0x5A) {
        // 'A'–'Z' → two decimal digits (A=10, …, Z=35)
        rem = (rem * 100 + (c - 0x41 + 10)) % 97;
      }
    }
    return rem;
  }
}

// ── Transaction serialization (Nimiq Albatross / PoS, little-endian) ──────────

class _NimiqTx {
  _NimiqTx._();

  static const int _maxMemoBytes = 64;

  /// Serialises the transaction body (the data that is signed).
  ///
  /// Albatross basic-transaction layout:
  ///   u8   network_id
  ///   u8   flags = 0  (basic)
  ///   20B  sender_address
  ///   u8   sender_type = 0  (Basic)
  ///   u16  sender_data_len = 0
  ///   20B  recipient_address
  ///   u8   recipient_type = 0  (Basic)
  ///   u16  recipient_data_len
  ///   NB   recipient_data  (optional memo)
  ///   u64  value  (Luna, LE)
  ///   u64  fee    (Luna, LE)
  ///   u32  validity_start_height  (LE)
  static Uint8List buildBody({
    required Uint8List sender,
    required Uint8List recipient,
    required int valueLuna,
    required int feeLuna,
    required int validityStartHeight,
    required int networkId,
    String? memo,
  }) {
    final memoBytes = memo != null
        ? Uint8List.fromList(utf8.encode(memo).take(_maxMemoBytes).toList())
        : Uint8List(0);

    final buf = BytesBuilder(copy: false);
    buf.addByte(networkId);
    buf.addByte(0); // flags = 0
    buf.add(sender); // 20 bytes
    buf.addByte(0); // sender_type = Basic
    _u16(buf, 0); // no sender data
    buf.add(recipient); // 20 bytes
    buf.addByte(0); // recipient_type = Basic
    _u16(buf, memoBytes.length);
    buf.add(memoBytes);
    _u64(buf, valueLuna);
    _u64(buf, feeLuna);
    _u32(buf, validityStartHeight);
    return buf.toBytes();
  }

  /// Appends the single-signer Ed25519 proof to the signed body.
  ///
  /// Proof (98 bytes):
  ///   u8   key_type = 0  (Ed25519)
  ///   32B  public_key
  ///   u8   merkle_path_count = 0  (no path)
  ///   64B  signature
  static Uint8List appendProof({
    required Uint8List txBody,
    required Uint8List publicKey,
    required Uint8List signature,
  }) {
    assert(publicKey.length == 32);
    assert(signature.length == 64);
    const proofLen = 1 + 32 + 1 + 64; // 98

    final proof = Uint8List(proofLen)
      ..[0] = 0x00 // KeyType::Ed25519
      ..setRange(1, 33, publicKey)
      ..[33] = 0x00 // empty Blake2bMerklePath
      ..setRange(34, 98, signature);

    final buf = BytesBuilder(copy: false);
    buf.add(txBody);
    _u16(buf, proofLen);
    buf.add(proof);
    return buf.toBytes();
  }

  // ── little-endian helpers ────────────────────────────────────────────────

  static void _u16(BytesBuilder b, int v) {
    b.addByte(v & 0xFF);
    b.addByte((v >> 8) & 0xFF);
  }

  static void _u32(BytesBuilder b, int v) {
    b.addByte(v & 0xFF);
    b.addByte((v >> 8) & 0xFF);
    b.addByte((v >> 16) & 0xFF);
    b.addByte((v >> 24) & 0xFF);
  }

  static void _u64(BytesBuilder b, int v) {
    _u32(b, v & 0xFFFFFFFF);
    _u32(b, (v >> 32) & 0xFFFFFFFF);
  }
}
