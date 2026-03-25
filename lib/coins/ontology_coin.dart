// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/ecc/curves/prime256v1.dart';
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

// ONT native contract address (little-endian hex, 20 bytes)
const _ontContractAddrHex = '0000000000000000000000000000000000000001';

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
Uint8List _ontAddressToHash(String address) {
  final decoded = neoOntB58Decode(address);
  if (decoded.length != 25) throw Exception('Invalid ONT address');
  return decoded.sublist(1, 21);
}

Uint8List _buildOntTransferScript(
  String fromAddress,
  String toAddress,
  int amount,
) {
  final fromHash = _ontAddressToHash(fromAddress);
  final toHash = _ontAddressToHash(toAddress);
  final contractAddr = Uint8List.fromList(HEX.decode(_ontContractAddrHex));

  final script = <int>[];

  void pushBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      script.add(0x00);
      return;
    }
    if (bytes.length <= 75) {
      script.add(bytes.length);
    } else if (bytes.length <= 255) {
      script
        ..add(0x4C)
        ..add(bytes.length);
    } else {
      script
        ..add(0x4D)
        ..add(bytes.length & 0xff)
        ..add((bytes.length >> 8) & 0xff);
    }
    script.addAll(bytes);
  }

  void pushInt(int value) {
    if (value == -1) {
      script.add(0x4F);
      return;
    }
    if (value == 0) {
      script.add(0x00);
      return;
    }
    if (value >= 1 && value <= 16) {
      script.add(0x50 + value);
      return;
    }
    final bytes = <int>[];
    int v = value;
    while (v > 0) {
      bytes.add(v & 0xff);
      v >>= 8;
    }
    if (bytes.last & 0x80 != 0) bytes.add(0x00);
    pushBytes(bytes);
  }

  pushInt(amount);
  pushBytes(toHash);
  pushBytes(fromHash);
  pushInt(3);
  script.add(0xC1); // PACK
  pushBytes(utf8.encode('transfer'));
  script.add(0x67);
  script.addAll(contractAddr); // APPCALL

  return Uint8List.fromList(script);
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
  final bool isTestnet_;

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
  int decimals() => 0;

  Future<Map<String, dynamic>> _rpc(String method, List params) =>
      neoOntRpc(rpcUrl, method, params);

  Future<dynamic> _rpcRaw(String method, List params) =>
      neoOntRpcRaw(rpcUrl, method, params);

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'ontCoinDetail_V5${isTestnet_}_${walletImportType.name}';
    Map<String, dynamic> cache = {};

    if (pref.containsKey(saveKey)) {
      cache = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (cache.containsKey(mnemonic)) {
        return AccountData.fromJson(cache[mnemonic]);
      }
    }
    final result = await compute(
      calculateOntologyKey,
      OntDeriveArgs(seedRoot: seedPhraseRoot, path: _ontDerivationPath),
    );

    cache[mnemonic] = result;
    await pref.put(saveKey, jsonEncode(cache));
    return AccountData.fromJson(result);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final result = await _rpc('getbalance', [address]);
    return double.tryParse(result['ont']?.toString() ?? '0') ?? 0.0;
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'ontBalance_${isTestnet_}_$address';
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

    final ontAmount = int.parse(amount.split('.').first);
    final script = _buildOntTransferScript(fromAddr, to, ontAmount);

    final blockCount = await _rpcRaw('getblockcount', []) as int;
    final nonce = blockCount & 0xffffffff;

    final payerHash = _ontAddressToHash(fromAddr);
    final payer = Uint8List(21)
      ..[0] = 0x00
      ..setRange(1, 21, payerHash);

    const gasPrice = 2500;
    const gasLimit = 20000;

    final txBody = Uint8List.fromList([
      0xd1,
      0x00,
      ...neoOntLeUInt32(nonce),
      ...neoOntLeUInt64(gasPrice),
      ...neoOntLeUInt64(gasLimit),
      ...payer,
      ...neoOntVarBytes(script),
    ]);

    // ONT: sign dsha256(txBody) directly — no inner re-hash (innerDigest = null).
    final txHash256 = neoOntDsha256(txBody);
    final signature = neoOntP256Sign(privBytes, txHash256);

    final verScript = _ontVerScript(pubKeyBytes);
    final invocScript = Uint8List(signature.length + 2)
      ..[0] = 0x40
      ..[1] = signature.length
      ..setRange(2, 2 + signature.length, signature);

    final sigRecord = Uint8List.fromList([
      ...neoOntVarInt(1),
      ...pubKeyBytes,
      ...neoOntVarBytes(invocScript),
      ...neoOntVarBytes(verScript),
    ]);

    final rawTx =
        Uint8List.fromList([...txBody, ...neoOntVarInt(1), ...sigRecord]);
    final rawTxHex = HEX.encode(rawTx);

    if (kDebugMode) print('ONT rawTx: $rawTxHex');

    final broadcastResult = await _rpc('sendrawtransaction', [rawTxHex]);
    final hash = broadcastResult['hash'] as String? ?? _calcTxHash(rawTx);

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
        .replaceFirst('/transaction/', '/address/')
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
        'payScheme': payScheme,
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
            'https://explorer.ont.io/transaction/$blockExplorerPlaceholder',
        image: 'assets/ontology.png',
        rpcUrl: 'http://polaris1.ont.io:20336',
        geckoID: 'ontology',
        rampID: '',
        payScheme: 'ontology',
        isTestnet_: true,
      ),
    ];
  }
  return [
    OntologyCoin(
      name: 'Ontology',
      symbol: 'ONT',
      default_: 'ONT',
      blockExplorer:
          'https://explorer.ont.io/transaction/$blockExplorerPlaceholder',
      image: 'assets/ontology.png',
      rpcUrl: 'http://dappnode1.ont.io:20336',
      geckoID: 'ontology',
      rampID: '',
      payScheme: 'ontology',
      isTestnet_: false,
    ),
  ];
}
