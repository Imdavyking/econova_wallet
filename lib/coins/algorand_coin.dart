// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';

import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:hive/hive.dart';
import 'package:algorand_dart/algorand_dart.dart' as algo_rand;

import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

const algorandDecimals = 6;

class AlgorandCoin extends Coin {
  AlgorandTypes algoType;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;

  AlgorandCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.algoType,
  });

  // ── Coin interface ──────────────────────────────────────────────────────────

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
  int decimals() => algorandDecimals;

  @override
  String getGeckoId() => 'algorand';

  @override
  String getRampID() => algoType == AlgorandTypes.mainNet ? 'ALGO_ALGO' : '';

  @override
  String getPayScheme() => 'algorand';

  // ── Serialization ───────────────────────────────────────────────────────────

  factory AlgorandCoin.fromJson(Map<String, dynamic> json) {
    return AlgorandCoin(
      algoType: json['algoType'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'algoType': algoType,
      'default': default_,
      'symbol': symbol,
      'name': name,
      'blockExplorer': blockExplorer,
      'image': image,
    };
  }

  // ── Key derivation ──────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final cacheKey = 'algorandDetails${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(cacheKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(cacheKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(
          Map<String, dynamic>.from(mnemonicMap[mnemonic]),
        );
      }
    }

    final keys = await compute(
      calculateAlgorandKey,
      AlgorandDeriveArgs(
        seedRoot: seedPhraseRoot,
        mnemonic: mnemonic,
      ),
    );

    mnemonicMap[mnemonic] = keys;
    await pref.put(cacheKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(Map<String, dynamic>.from(keys));
  }

  // ── Balance ─────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final microAlgos = await getAlgorandClient(algoType).getBalance(address);
    return microAlgos / pow(10, algorandDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'algorandAddressBalance$address${algoType.index}';
    final storedBalance = pref.get(key);
    double savedBalance = storedBalance ?? 0;

    if (useCache) return savedBalance;

    try {
      final balance = await getUserBalance(address: address);
      await pref.put(key, balance);
      return balance;
    } catch (e) {
      return savedBalance;
    }
  }

  // ── Transfer ─────────────────────────────────────────────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;

    // Re-derive the full Account object (with signing capability) from seed.
    final account = await compute(
      _deriveAlgorandAccount,
      AlgorandDeriveArgs(
        seedRoot: seedPhraseRoot,
        mnemonic: data,
      ),
    );

    String txHash;
    try {
      txHash = await getAlgorandClient(algoType).sendPayment(
        account: account,
        recipient: algo_rand.Address.fromAlgorandAddress(address: to),
        amount: algo_rand.Algo.toMicroAlgos(double.parse(amount)),
        note: memo,
      );
    } on algo_rand.AlgorandException catch (e) {
      throw e.message;
    }

    return (txHash: txHash, txRaw: null);
  }

  // ── Misc ────────────────────────────────────────────────────────────────────

  @override
  void validateAddress(String address) {
    algo_rand.Address.fromAlgorandAddress(address: address);
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async => 0.001;

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }
}

// ── Registry ──────────────────────────────────────────────────────────────────

List<AlgorandCoin> getAlgorandBlockchains() {
  if (enableTestNet) {
    return [
      AlgorandCoin(
        blockExplorer:
            'https://testnet.algoexplorer.io/tx/$blockExplorerPlaceholder',
        symbol: 'ALGO',
        name: 'Algorand(Testnet)',
        default_: 'ALGO',
        image: 'assets/algorand.png',
        algoType: AlgorandTypes.testNet,
      ),
    ];
  }
  return [
    AlgorandCoin(
      blockExplorer: 'https://algoexplorer.io/tx/$blockExplorerPlaceholder',
      symbol: 'ALGO',
      name: 'Algorand',
      default_: 'ALGO',
      image: 'assets/algorand.png',
      algoType: AlgorandTypes.mainNet,
    ),
  ];
}

enum AlgorandTypes { mainNet, testNet }

// ── Algorand client factory ───────────────────────────────────────────────────

algo_rand.Algorand getAlgorandClient(AlgorandTypes type) {
  final algodClient = algo_rand.AlgodClient(
    apiUrl: type == AlgorandTypes.mainNet
        ? algo_rand.PureStake.MAINNET_ALGOD_API_URL
        : algo_rand.PureStake.TESTNET_ALGOD_API_URL,
    apiKey: pureStakeApiKey,
    tokenKey: algo_rand.PureStake.API_TOKEN_HEADER,
  );

  final indexerClient = algo_rand.IndexerClient(
    apiUrl: type == AlgorandTypes.mainNet
        ? algo_rand.PureStake.MAINNET_INDEXER_API_URL
        : algo_rand.PureStake.TESTNET_INDEXER_API_URL,
    apiKey: pureStakeApiKey,
    tokenKey: algo_rand.PureStake.API_TOKEN_HEADER,
  );

  final kmdClient = algo_rand.KmdClient(
    apiUrl: '127.0.0.1',
    apiKey: pureStakeApiKey,
  );

  return algo_rand.Algorand(
    algodClient: algodClient,
    indexerClient: indexerClient,
    kmdClient: kmdClient,
  );
}

// ── Isolate args & key derivation ─────────────────────────────────────────────

class AlgorandDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String mnemonic;

  const AlgorandDeriveArgs({
    required this.seedRoot,
    required this.mnemonic,
  });
}

/// Returns a serialisable [Map] with just the address (used by [fromMnemonic]).
Future<Map<String, dynamic>> calculateAlgorandKey(
    AlgorandDeriveArgs args) async {
  final account = await _deriveAlgorandAccount(args);
  return {'address': account.publicAddress};
}

/// Returns the full [algo_rand.Account] — used when signing is needed.
Future<algo_rand.Account> _deriveAlgorandAccount(
    AlgorandDeriveArgs args) async {
  final masterKey = await ED25519_HD_KEY.derivePath(
    "m/44'/283'/0'/0'/0'",
    args.seedRoot.seed,
  );
  return algo_rand.Account.fromPrivateKey(HEX.encode(masterKey.key));
}
