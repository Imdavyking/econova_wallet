// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/ecc/curves/prime256v1.dart';
import 'package:pointycastle/export.dart' as pc;
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/neo_ont_utils.dart';
import '../utils/rpc_urls.dart';

// NEO N3 — NIST P-256 (secp256r1 / prime256v1), BIP44 coin type 888
// Derivation : m/44'/888'/0'/0/0
// Address    : Base58Check(0x35 || LE(RIPEMD160(SHA256(verificationScript))))
// Transfer   : NEO N3 RPC invokefunction via ContractManagement
//              Signed with P-256 (ECDSA) — DER encoded

const _neoDerivationPath = "m/44'/888'/0'/0/0";

const _neoContractHash = '0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5';
const _neoAddressVersion = 0x35;

// ─── Key derivation ────────────────────────────────────────────────────────

class NeoDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String path;
  const NeoDeriveArgs({required this.seedRoot, required this.path});
}

Map<String, dynamic> calculateNeoKey(NeoDeriveArgs args) {
  // SLIP-0010 Nist256p1 — HMAC key = "Nist256p1 seed"
  final privBytes = slip10Nist256p1Derive(
    args.seedRoot.seed, // raw BIP39 seed bytes
    args.path,
  );

  final curve = ECCurve_prime256v1();
  final d = BigInt.parse(HEX.encode(privBytes), radix: 16);
  final pubKey = (curve.G * d)!.getEncoded(true);

  final verScript = _neoVerScript(pubKey);
  final leScriptHash = Uint8List.fromList(
    neoOntHash160(verScript).reversed.toList(),
  );
  final address = neoOntB58CheckEncode(_neoAddressVersion, leScriptHash);

  return {
    'address': address,
    'privateKey': HEX.encode(privBytes),
    'publicKey': HEX.encode(pubKey),
  };
}

Uint8List _neoVerScript(Uint8List pubKey) => Uint8List(40)
  ..[0] = 0x0C
  ..[1] = 0x21
  ..setRange(2, 35, pubKey)
  ..[35] = 0x41
  ..[36] = 0x56
  ..[37] = 0xe7
  ..[38] = 0xb3
  ..[39] = 0x27;

// ─── NEO N3 script / serialisation helpers ─────────────────────────────────

/// Decodes a NEO N3 address back to its 20-byte script hash (LE → BE).
Uint8List _neoAddressToScriptHash(String address) {
  final decoded = neoOntB58Decode(address);
  if (decoded.length != 25) throw Exception('Invalid NEO address length');
  return Uint8List.fromList(decoded.sublist(1, 21).reversed.toList());
}

Uint8List _buildNeoTransferScript(
  String fromAddress,
  String toAddress,
  int amount,
) {
  final fromHash = _neoAddressToScriptHash(fromAddress);
  final toHash = _neoAddressToScriptHash(toAddress);
  final contractHash = Uint8List.fromList(
    HEX.decode(_neoContractHash.replaceFirst('0x', '')).reversed.toList(),
  );

  final script = <int>[];

  script.add(0x0F); // PUSHNULL (data param)

  if (amount == 0) {
    script.add(0x10);
  } else if (amount <= 16) {
    script.add(0x10 + amount);
  } else {
    script.add(0x03);
    script.addAll(neoOntLeInt64(amount));
  }

  script
    ..add(0x0C)
    ..add(toHash.length)
    ..addAll(toHash);
  script
    ..add(0x0C)
    ..add(fromHash.length)
    ..addAll(fromHash);
  script.add(0x14); // PUSH4 (param count)
  script.add(0xC0); // PACK

  final methodBytes = utf8.encode('transfer');
  script
    ..add(0x0C)
    ..add(methodBytes.length)
    ..addAll(methodBytes);

  script
    ..add(0x0C)
    ..add(contractHash.length)
    ..addAll(contractHash);
  script.add(0x1F); // PUSH15 (CallFlags.All)

  script.add(0x41);
  script.addAll([0x62, 0x7d, 0x5b, 0x52]); // SYSCALL System.Contract.Call

  return Uint8List.fromList(script);
}

// ─── NeoCoin ───────────────────────────────────────────────────────────────

class NeoCoin extends Coin {
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

  NeoCoin({
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
    final saveKey = 'neoCoinDetail_${isTestnet_}_${walletImportType.name}';
    Map<String, dynamic> cache = {};
    if (pref.containsKey(saveKey)) {
      cache = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (cache.containsKey(mnemonic)) {
        return AccountData.fromJson(cache[mnemonic]);
      }
    }
    final result = await compute(
      calculateNeoKey,
      NeoDeriveArgs(
        seedRoot: seedPhraseRoot,
        path: _neoDerivationPath,
      ),
    );
    cache[mnemonic] = result;
    await pref.put(saveKey, jsonEncode(cache));
    return AccountData.fromJson(result);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final result = await _rpc('getnep17balances', [address]);
    final balances = result['balance'] as List? ?? [];
    for (final item in balances) {
      if ((item['assethash'] as String).toLowerCase() ==
          _neoContractHash.toLowerCase()) {
        return double.tryParse(item['amount'].toString()) ?? 0.0;
      }
    }
    return 0.0;
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'neoBalance_${isTestnet_}_$address';
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

    final neoAmount = int.parse(amount.split('.').first);
    final script = _buildNeoTransferScript(fromAddr, to, neoAmount);

    final invokeResult = await _rpc('invokescript', [
      base64Encode(script),
      [
        {'account': fromAddr}
      ],
    ]);

    final systemFee =
        (double.tryParse(invokeResult['gasconsumed']?.toString() ?? '0') ?? 0.0)
            .ceil();

    final blockCount = await _rpcRaw('getblockcount', []) as int;
    final validUntilBlock = blockCount + 50;

    final nonce = DateTime.now().millisecondsSinceEpoch & 0xffffffff;
    const networkFee = 1500000;

    final signerHash = _neoAddressToScriptHash(fromAddr);
    final signer = Uint8List.fromList([...signerHash, 0x01]);

    final txBody = Uint8List.fromList([
      0x00,
      ...neoOntLeUInt32(nonce),
      ...neoOntLeInt64(systemFee),
      ...neoOntLeInt64(networkFee),
      ...neoOntLeUInt32(validUntilBlock),
      ...neoOntVarInt(1),
      ...signer,
      ...neoOntVarInt(0),
      ...neoOntVarBytes(script),
    ]);

    // NEO N3: sign SHA256(dsha256(txBody)) — SHA256Digest hashes internally.
    final txHash256 = neoOntDsha256(txBody);
    final signature = neoOntP256Sign(
      privBytes,
      txHash256,
      innerDigest: pc.SHA256Digest(),
    );

    final verScript = _neoVerScript(pubKeyBytes);
    final invocScript = Uint8List(66)
      ..[0] = 0x0C
      ..[1] = 0x40
      ..setRange(2, 66, signature);

    final witness = Uint8List.fromList([
      ...neoOntVarBytes(invocScript),
      ...neoOntVarBytes(verScript),
    ]);

    final rawTx = Uint8List.fromList([
      ...txBody,
      ...neoOntVarInt(1),
      ...witness,
    ]);

    final rawTxBase64 = base64Encode(rawTx);
    final rawTxHex = HEX.encode(rawTx);

    if (kDebugMode) print('NEO rawTx: $rawTxHex');

    final broadcastResult = await _rpc('sendrawtransaction', [rawTxBase64]);
    final hash = broadcastResult['hash'] as String? ?? rawTxHex;

    return (txHash: hash, txRaw: rawTxHex);
  }

  @override
  void validateAddress(String address) {
    try {
      final decoded = neoOntB58CheckDecode(address);
      if (decoded.length != 25) throw Exception('bad length');
      if (decoded[0] != _neoAddressVersion) throw Exception('bad version');
    } catch (e) {
      throw Exception('Invalid NEO address: $e');
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
        'type': 'NeoCoin',
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

List<NeoCoin> getNeoBlockChains() {
  if (enableTestNet) {
    return [
      NeoCoin(
        name: 'NEO (Testnet)',
        symbol: 'NEO',
        default_: 'NEO',
        blockExplorer:
            'https://testnet.neoscan.io/transaction/$blockExplorerPlaceholder',
        image: 'assets/neo.png',
        rpcUrl: 'http://seed1.ngd.network:20332',
        geckoID: 'neo',
        rampID: '',
        payScheme: 'neo',
        isTestnet_: true,
      ),
    ];
  }
  return [
    NeoCoin(
      name: 'NEO',
      symbol: 'NEO',
      default_: 'NEO',
      blockExplorer: 'https://neoscan.io/transaction/$blockExplorerPlaceholder',
      image: 'assets/neo.png',
      rpcUrl: 'http://seed1.ngd.network:10332',
      geckoID: 'neo',
      rampID: '',
      payScheme: 'neo',
      isTestnet_: false,
    ),
  ];
}
