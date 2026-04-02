// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/ecc/curves/prime256v1.dart';
import 'package:wallet_app/coins/fungible_tokens/ontology_ft_coin.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/neo_ont_utils.dart';
import '../utils/rpc_urls.dart';

// Ontology — NIST P-256 (secp256r1 / prime256v1), BIP44 coin type 1024
// Derivation : m/44'/1024'/0'/0/0
// Address    : Base58Check(0x41 || RIPEMD160(SHA256(verificationScript)))
//              (big-endian script hash — unlike NEO which uses little-endian)
// Transfer   : InvokeCode transaction (type 0xd1), P-256 ECDSA signed

const _ontDerivationPath = "m/44'/1024'/0'/0/0";
const _ontAddressVersion = 0x17;

// ─── Key derivation ────────────────────────────────────────────────────────

class OntDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String path;
  const OntDeriveArgs({required this.seedRoot, required this.path});
}

Map<String, dynamic> calculateOntologyKey(OntDeriveArgs args) {
  // SLIP-0010 Nist256p1 — HMAC key = "Nist256p1 seed"
  final privBytes = slip10Nist256p1Derive(
    args.seedRoot.seed, // raw BIP39 seed bytes
    args.path,
  );

  final curve = ECCurve_prime256v1();
  final d = BigInt.parse(HEX.encode(privBytes), radix: 16);
  final pubKey = (curve.G * d)!.getEncoded(true); // 33 bytes compressed

  final verScript = _ontVerScript(pubKey);
  final scriptHash = neoOntHash160(verScript);
  final address = neoOntB58CheckEncode(_ontAddressVersion, scriptHash);

  return {
    'address': address,
    'privateKey': HEX.encode(privBytes),
    'publicKey': HEX.encode(pubKey),
  };
}

Uint8List _ontVerScript(Uint8List pubKey) => Uint8List(pubKey.length + 2)
  ..[0] = 0x21
  ..setRange(1, pubKey.length + 1, pubKey)
  ..[pubKey.length + 1] = 0xAC;

// ─── ONT address / script helpers ─────────────────────────────────────────

/// Decode ONT address to 20-byte script hash (big-endian, no reversal).
// Uint8List _ontAddressToHash(String address) {
//   final decoded = neoOntB58Decode(address);
//   if (decoded.length != 25) throw Exception('Invalid ONT address');
//   return decoded.sublist(1, 21);
// }

Uint8List _ontAddressToHash(String address) {
  final decoded = neoOntB58CheckDecode(address);
  if (decoded.length != 25) throw Exception('Invalid ONT address length');
  if (decoded[0] != _ontAddressVersion) {
    throw Exception('Wrong version byte');
  }
  return decoded.sublist(1, 21);
}
// ─── OntologyCoin ──────────────────────────────────────────────────────────

class OntologyCoin extends Coin {
  final String blockExplorer;
  final String rpcUrl;
  final String symbol;
  final String default_;
  final String image;
  final String name;
  final String geckoID;
  final String rampID;
  final String payScheme;
  final String contractAddress;
  final bool isTestnet_;
  final int coinDecimals;
  final String caipReference;

  OntologyCoin({
    required this.blockExplorer,
    required this.rpcUrl,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    required this.contractAddress,
    required this.isTestnet_,
    required this.coinDecimals,
    required this.caipReference,
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
  int decimals() => coinDecimals;

  @override
  String get caip2Namespace => 'ont';
  @override
  String get caip2Reference => caipReference;

  Future<Map<String, dynamic>> _rpc(String method, List params) =>
      neoOntRpc(rpcUrl, method, params);

  Future<dynamic> _rpcRaw(String method, List params) =>
      neoOntRpcRaw(rpcUrl, method, params);

  @override
  bool get supportBip39Seed => true;

  @override
  Future<AccountData> fromBip39PhraseOrSeed(
          {required String bip39PhraseOrSeedHex}) =>
      Coin.fromBip39PhraseOrSeedCached(
        cacheKey: 'ontCoinDetail_V5${isTestnet_}_${walletImportType.name}',
        bip39PhraseOrSeedHex: bip39PhraseOrSeedHex,
        derive: () => compute(
          calculateOntologyKey,
          OntDeriveArgs(seedRoot: seedPhraseRoot, path: _ontDerivationPath),
        ),
      );

  @override
  Future<double> getUserBalance({required String address}) async {
    final result = await _rpc('getbalance', [address]);
    final balanceStr = result[getSymbol().toLowerCase()]?.toString() ?? '0';
    final balanceBigInt = BigInt.tryParse(balanceStr) ?? BigInt.zero;
    final divisor = BigInt.from(10).pow(decimals());
    return balanceBigInt.toDouble() / divisor.toDouble();
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'ontBalance_${isTestnet_}_$address$contractAddress';
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

  Uint8List _buildOntTransferScript(
    String fromAddress,
    String toAddress,
    int amount,
  ) {
    final fromHash = _ontAddressToHash(fromAddress);
    final toHash = _ontAddressToHash(toAddress);
    // "Ontology.Native.Invoke" constant
    final nativeInvoke =
        Uint8List.fromList(utf8.encode('Ontology.Native.Invoke'));
    final methodName = Uint8List.fromList(utf8.encode('transfer'));
    final contractAddr = Uint8List.fromList(HEX.decode(contractAddress));

    final s = <int>[];

    // pushHexString equivalent: raw len prefix for ≤75 bytes
    void push(List<int> bytes) {
      final n = bytes.length;
      if (n <= 75) {
        s.add(n);
      } else if (n < 0x100) {
        s
          ..add(0x4C)
          ..add(n);
      } else {
        s
          ..add(0x4D)
          ..add(n & 0xff)
          ..add((n >> 8) & 0xff);
      }
      s.addAll(bytes);
    }

    void pushInt(int v) {
      if (v == 0) {
        s.add(0x00); // PUSH0
      } else if (v >= 1 && v <= 16) {
        s.add(0x50 + v); // PUSH1..PUSH16
      } else {
        final bytes = <int>[];
        int x = v;
        while (x > 0) {
          bytes.add(x & 0xff);
          x >>= 8;
        }
        if (bytes.last & 0x80 != 0) bytes.add(0x00);
        push(bytes);
      }
    }

    // ── NeoVM struct: PUSH0 + NEWSTRUCT + TOALTSTACK ──────────────────────
    s.add(0x00); // PUSH0
    s.add(0xc6); // NEWSTRUCT
    s.add(0x6b); // TOALTSTACK

    // from
    push(fromHash);
    s
      ..add(0x6a)
      ..add(0x7c)
      ..add(0xc8); // DUP_FROM_ALT + SWAP + APPEND
    // to
    push(toHash);
    s
      ..add(0x6a)
      ..add(0x7c)
      ..add(0xc8);
    // amount
    pushInt(amount);
    s
      ..add(0x6a)
      ..add(0x7c)
      ..add(0xc8);

    s.add(0x6c); // FROMALTSTACK

    // wrap in a 1-element array
    s.add(0x51); // PUSH1
    s.add(0xc1); // PACK

    // ── method + contract + SYSCALL ──────────────────────────────────────
    push(methodName); // 0x08 + "transfer"
    push(contractAddr); // 0x14 + 20-byte contract address
    s.add(0x00); // PUSH0 (extra arg)
    s.add(0x68); // SYSCALL opcode
    push(nativeInvoke); // 0x16 + "Ontology.Native.Invoke"

    return Uint8List.fromList(s);
  }

  @override
  List<Coin> get networkTokens => getOntologyFungibleCoins();
  @override
  Future<double> getTransactionFee(String amount, String to) async => 0.01;

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final walletData = WalletService.getActiveKey(walletImportType)!.data;
    final keyData = await importData(walletData);
    final fromAddr = keyData.address;
    final privBytes = Uint8List.fromList(HEX.decode(keyData.privateKey!));
    final pubKeyBytes = Uint8List.fromList(HEX.decode(keyData.publicKey!));

    final ontAmount = amount.toBigIntDec(decimals()).toInt();
    final script = _buildOntTransferScript(fromAddr, to, ontAmount);

    final blockCount = await _rpcRaw('getblockcount', []) as int;
    final nonce = blockCount & 0xffffffff;
    final payer = _ontAddressToHash(fromAddr);

    const gasPrice = 2500;
    const gasLimit = 20000;

    // Unsigned body — trailing 0x00 is the sig-count placeholder the SDK
    // includes in the hash pre-image (serializeUnsignedData ends with 0x00)
    final txUnsigned = Uint8List.fromList([
      0x00, 0xd1,
      ...neoOntLeUInt32(nonce),
      ...neoOntLeUInt64(gasPrice),
      ...neoOntLeUInt64(gasLimit),
      ...payer,
      ...neoOntVarBytes(script),
      ...neoOntVarInt(0), // attributes count = 0
      0x00, // sig count placeholder for hash pre-image
    ]);

    if (kDebugMode) {
      print('=== DART unsigned tx hex ===');
      print(HEX.encode(txUnsigned));
      print('=== DART unsigned tx hex END ===');
    }

    // Single SHA256 of the unsigned body (matches SDK serializeUnsignedData)
    final signature = neoOntP256SignOnt(privBytes, txUnsigned);

    // ONT invocation script: 0x41 (push 65 bytes) + 0x01 (ECDSA algo id) + sig
    // This differs from NEO which uses 0x40 + sig
    final invocationScript =
        Uint8List.fromList([0x41, 0x01, ...signature]); // 66 bytes
    final verificationScript =
        Uint8List.fromList([0x21, ...pubKeyBytes, 0xAC]); // 35 bytes

    final sigRecord = Uint8List.fromList([
      ...neoOntVarBytes(invocationScript), // 0x42 + 66 bytes
      ...neoOntVarBytes(verificationScript), // 0x23 + 35 bytes
    ]);

    // Strip the trailing 0x00 placeholder, replace with 0x01 + sigRecord
    final txBase = txUnsigned.sublist(0, txUnsigned.length - 1);
    final rawTx = Uint8List.fromList([
      ...txBase,
      0x01, // VarInt(1) sig records
      ...sigRecord,
    ]);

    final rawTxHex = HEX.encode(rawTx);
    if (kDebugMode) print('ONT rawTx: $rawTxHex');

    final broadcastResult = await _rpc('sendrawtransaction', [rawTxHex]);
    debugPrint('data sent: ${broadcastResult.toString()}');

    final hash = broadcastResult['hash'] as String? ?? _calcTxHash(txUnsigned);
    return (txHash: hash, txRaw: rawTxHex);
  }

  String _calcTxHash(Uint8List rawTx) {
    final hash = neoOntDsha256(rawTx);
    return '0x${HEX.encode(Uint8List.fromList(hash.reversed.toList()))}';
  }

  @override
  void validateAddress(String address) {
    try {
      final decoded = neoOntB58CheckDecode(address);
      if (decoded.length != 25) throw Exception('bad length');
      if (decoded[0] != _ontAddressVersion) throw Exception('bad version byte');
    } catch (e) {
      throw Exception('Invalid ONT address: $e');
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
  Map<String, dynamic> toJson() => {
        'type': 'OntologyCoin',
        'isTestnet': isTestnet_,
        'symbol': symbol,
        'blockExplorer': blockExplorer,
        'rpcUrl': rpcUrl,
        'name': name,
        'image': image,
        'geckoID': geckoID,
        'rampID': rampID,
        'decimals': coinDecimals,
        'payScheme': payScheme,
        'contractAddress': contractAddress,
        'caipReference': caipReference,
      };
}

// ─── Factory ───────────────────────────────────────────────────────────────

List<OntologyCoin> getOntologyBlockChains() {
  if (enableTestNet) {
    return [
      OntologyCoin(
        name: 'Ontology (Testnet)',
        symbol: 'ONT',
        default_: 'ONT',
        blockExplorer:
            'https://explorer.ont.io/testnet/tx/$blockExplorerPlaceholder',
        image: 'assets/ontology.png',
        rpcUrl: 'http://polaris1.ont.io:20336',
        geckoID: 'ontology',
        rampID: '',
        payScheme: 'ontology',
        isTestnet_: true,
        coinDecimals: 0,
        contractAddress: '0000000000000000000000000000000000000001',
        caipReference: '2',
      ),
    ];
  }

  return [
    OntologyCoin(
      name: 'Ontology',
      symbol: 'ONT',
      default_: 'ONT',
      blockExplorer: 'https://explorer.ont.io/tx/$blockExplorerPlaceholder',
      image: 'assets/ontology.png',
      rpcUrl: 'http://dappnode1.ont.io:20336',
      geckoID: 'ontology',
      rampID: '',
      payScheme: 'ontology',
      coinDecimals: 0,
      isTestnet_: false,
      contractAddress: '0000000000000000000000000000000000000001',
      caipReference: '1',
    ),
  ];
}
