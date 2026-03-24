// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/digests/sha3.dart';
import 'package:web3dart/crypto.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:pointycastle/export.dart' as pc;
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

const iconDecimals = 18;

class IconCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String api;
  String geckoID;
  String rampID;
  String payScheme;
  String nid;

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
  int decimals() => iconDecimals;
  @override
  String getGeckoId() => geckoID;
  @override
  String getPayScheme() => payScheme;
  @override
  String getRampID() => rampID;

  IconCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    required this.nid,
  });

  factory IconCoin.fromJson(Map<String, dynamic> json) => IconCoin(
        blockExplorer: json['blockExplorer'],
        symbol: json['symbol'],
        default_: json['default'],
        image: json['image'],
        name: json['name'],
        api: json['api'],
        geckoID: json['geckoID'],
        rampID: json['rampID'],
        payScheme: json['payScheme'],
        nid: json['nid'] ?? '0x1',
      );

  @override
  Map<String, dynamic> toJson() => {
        'blockExplorer': blockExplorer,
        'symbol': symbol,
        'default': default_,
        'image': image,
        'name': name,
        'api': api,
        'geckoID': geckoID,
        'rampID': rampID,
        'payScheme': payScheme,
        'nid': nid,
      };

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'iconCoinDetailsV423456${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = IconDeriveArgs(seedRoot: seedPhraseRoot);
    final keys = await compute(calculateIconKey, args);

    mnemonicMap[mnemonic] = keys;
    await pref.put(saveKey, jsonEncode(mnemonicMap));
    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final response = await http.post(
      Uri.parse(api),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'icx_getBalance',
        'id': 1,
        'params': {'address': address},
      }),
    );

    if (response.statusCode ~/ 100 != 2) {
      throw Exception('ICON balance failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    if (data['error'] != null) throw Exception(data['error']['message']);

    final hexBalance = data['result'] as String;
    final balance = BigInt.parse(
      hexBalance.replaceFirst('0x', ''),
      radix: 16,
    );
    return balance / BigInt.from(10).pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'iconBalance$address$api';
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
  Future<double> getTransactionFee(String amount, String to) async {
    // stepLimit(100_000) * stepPrice(12.5 Gloop) ≈ 0.00125 ICX
    return 0.00125;
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);

    final loopToSend = amount.toBigIntDec(decimals());
    final valueHex = '0x${loopToSend.toRadixString(16)}';
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final timestampHex = '0x${timestamp.toRadixString(16)}';

    final params = <String, String>{
      'version': '0x3',
      'from': details.address,
      'to': to,
      'value': valueHex,
      'stepLimit': '0x186a0', // 100_000
      'timestamp': timestampHex,
      'nid': nid,
      'nonce': '0x1',
    };

    if (memo != null && memo.isNotEmpty) {
      params['dataType'] = 'message';
      params['data'] = '0x${HEX.encode(utf8.encode(memo))}';
    }

    // Serialize and sign
    final serialized = _iconSerialize(params);
    final msgHash = _sha3_256(Uint8List.fromList(utf8.encode(serialized)));

    final privKey = Uint8List.fromList(
      HEX.decode(details.privateKey!.replaceFirst('0x', '')),
    );

    final sig = sign(msgHash, privKey);

    // ICON signature format: r(32) + s(32) + v(1, recovery id)
    final sigBytes = Uint8List(65)
      ..setAll(0, _padTo32(sig.r.toUint8List()))
      ..setAll(32, _padTo32(sig.s.toUint8List()))
      ..[64] = sig.v - 27;

    params['signature'] = base64.encode(sigBytes);

    final response = await http.post(
      Uri.parse(api),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'icx_sendTransaction',
        'id': 1,
        'params': params,
      }),
    );

    if (response.statusCode ~/ 100 != 2) {
      throw Exception('ICON transfer failed: ${response.body}');
    }

    final result = jsonDecode(response.body);
    if (result['error'] != null) {
      throw Exception('ICON error: ${result['error']['message']}');
    }

    return (txHash: result['result'] as String, txRaw: null);
  }

  @override
  validateAddress(String address) {
    if (!address.startsWith('hx') || address.length != 42) {
      throw Exception('Invalid ICX address');
    }
    try {
      HEX.decode(address.substring(2));
    } catch (_) {
      throw Exception('Invalid ICX address');
    }
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/transaction/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }
}

// ─── ICON transaction serialization ──────────────────────────────────────────
// Format: icx_sendTransaction.key1.val1.key2.val2 (keys sorted alphabetically)

String _iconSerialize(Map<String, String> params) {
  final sortedKeys = params.keys.toList()..sort();
  final parts = sortedKeys.map((k) => '$k.${_iconEscape(params[k]!)}');
  return 'icx_sendTransaction.${parts.join('.')}';
}

String _iconEscape(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll('.', '\\.')
    .replaceAll('{', '\\{')
    .replaceAll('}', '\\}')
    .replaceAll('[', '\\[')
    .replaceAll(']', '\\]');

// ─── SHA3-256 (NIST standard — NOT keccak256) ─────────────────────────────────

Uint8List _sha3_256(Uint8List data) {
  final digest = SHA3Digest(256);
  final output = Uint8List(32);
  digest.update(data, 0, data.length);
  digest.doFinal(output, 0);
  return output;
}

// ─── Pad BigInt bytes to 32 bytes ────────────────────────────────────────────

Uint8List _padTo32(Uint8List bytes) {
  if (bytes.length == 32) return bytes;
  final padded = Uint8List(32);
  padded.setAll(32 - bytes.length, bytes);
  return padded;
}

// ─── Key derivation ───────────────────────────────────────────────────────────
// ICON address = "hx" + last 20 bytes of SHA3-256(uncompressed pubkey)

class IconDeriveArgs {
  final SeedPhraseRoot seedRoot;
  const IconDeriveArgs({required this.seedRoot});
}

Future<Map<String, dynamic>> calculateIconKey(IconDeriveArgs args) async {
  const path = "m/44'/74'/0'/0/0";
  final node = args.seedRoot.root.derivePath(path);
  final privateKeyBytes = node.privateKey!;
  final privateKey = '0x${HEX.encode(privateKeyBytes)}';

  final bigIntPrivKey = BigInt.parse(HEX.encode(privateKeyBytes), radix: 16);
  final point = (pc.ECDomainParameters('secp256k1').G * bigIntPrivKey)!;
  final encoded = point.getEncoded(false); // 65 bytes
  final pub64 = encoded.sublist(1, 65); // 64 bytes, no 04 prefix

  // ICON uses SHA3-256 (NIST), NOT keccak256
  final hash = _sha3_256(pub64);
  final iconAddress = 'hx${HEX.encode(hash.sublist(12))}';
  return {
    'address': iconAddress,
    'privateKey': privateKey,
  };
}

List<IconCoin> getIconBlockChains() {
  if (enableTestNet) {
    return [
      IconCoin(
        name: 'ICON (Testnet)',
        symbol: 'ICX',
        default_: 'ICX',
        image: 'assets/icon.png',
        blockExplorer:
            'https://tracker.berlin.icon.community/transaction/$blockExplorerPlaceholder',
        api: 'https://berlin.net.solidwallet.io/api/v3',
        geckoID: 'icon',
        rampID: '',
        payScheme: 'icon',
        nid: '0x7',
      ),
    ];
  }

  return [
    IconCoin(
      name: 'ICON',
      symbol: 'ICX',
      default_: 'ICX',
      image: 'assets/icon.png',
      blockExplorer:
          'https://tracker.icon.community/transaction/$blockExplorerPlaceholder',
      api: 'https://api.icon.community/api/v3',
      geckoID: 'icon',
      rampID: '',
      payScheme: 'icon',
      nid: '0x1',
    ),
  ];
}
