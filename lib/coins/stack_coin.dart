// coins/stacks_coin.dart
// ignore_for_file: non_constant_identifier_names, unused_element

import 'dart:convert';
import 'dart:typed_data';

import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/utils/rpc_urls.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/pos_networks.dart';
import '../utils/c32check.dart';
import '../utils/stack_tx_utils.dart';

// ─── Address version bytes ─────────────────────────────────────────────────────

const int _versionMainnetP2PKH = 22; // SP…
const int _versionMainnetP2SH = 20; // SM…
const int _versionTestnetP2PKH = 26; // ST…
const int _versionTestnetP2SH = 21; // SN…

// ─── Transaction version / chain-ID ───────────────────────────────────────────

const int _txVersionMainnet = 0x00;
const int _txVersionTestnet = 0x80;
const int _chainIdMainnet = 0x00000001;
const int _chainIdTestnet = 0x80000000;

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

  // ─── Internal accessors ─────────────────────────────────────────────────────

  String get _api =>
      isTestnet ? 'https://api.testnet.hiro.so' : 'https://api.hiro.so';
  int get _addrVersion =>
      isTestnet ? _versionTestnetP2PKH : _versionMainnetP2PKH;
  int get _txVersion => isTestnet ? _txVersionTestnet : _txVersionMainnet;
  int get _chainId => isTestnet ? _chainIdTestnet : _chainIdMainnet;

  // ─── Coin interface ─────────────────────────────────────────────────────────

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

  static const int _stacksDecimals = 6;

  // ─── Serialization ──────────────────────────────────────────────────────────

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
    final pubBytes = stacksCompressedPubKey(privBytes);
    final address =
        'S${c32checkEncode(_addrVersion, HEX.encode(stacksHash160(pubBytes)))}';
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
    return micro / BigInt.from(stacksMicroPerStx);
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
    return (ratePerByte * stacksEstimatedStxTxBytes) / stacksMicroPerStx;
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
    final senderHash160 = stacksHash160(stacksCompressedPubKey(privBytes));

    final nonce = await _fetchNonce(keyPair.address);
    final feeRate = await _fetchFeeRate();
    final fee = BigInt.from(feeRate * stacksEstimatedStxTxBytes);
    final microStx =
        BigInt.from((double.parse(amount) * stacksMicroPerStx).toInt());

    final decoded = c32checkDecode(to.substring(1));
    final recipientVersion = decoded[0] as int;
    final recipientHash160 =
        Uint8List.fromList(HEX.decode(decoded[1] as String));

    final memoStr = (memo ?? '').trim();

    // Build STX token-transfer payload
    final payload = (BytesBuilder()
          ..addByte(stacksPayloadTokenTransfer)
          ..addByte(stacksPrincipalTypeStandard)
          ..addByte(recipientVersion)
          ..add(recipientHash160)
          ..add(stacksU64BE(microStx))
          ..add(stacksMemoBytes(memoStr)))
        .toBytes();

    final txBytes = stacksBuildSignedTx(
      txVersion: _txVersion,
      chainId: _chainId,
      privKey: privBytes,
      senderHash160: senderHash160,
      nonce: BigInt.from(nonce),
      fee: fee,
      payload: payload,
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

/// Top-level function so compute() can spawn it in an isolate.
Map<String, dynamic> calculateStacksKey(StacksDeriveArgs args) {
  final node = args.seedRoot.root.derivePath(args.derivationPath);

  final pubKeyBytes = stacksCompressedPubKey(node.privateKey!);
  final hash160 = stacksHash160(pubKeyBytes);

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
