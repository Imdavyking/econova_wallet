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
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

const algorandDecimals = 6;

//  'Coin.getGeckoId', 'Coin.getPayScheme', and 'Coin.getRampID'.
class AlgorandCoin extends Coin {
  AlgorandTypes algoType;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;

  AlgorandCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.algoType,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory AlgorandCoin.fromJson(Map<String, dynamic> json) {
    return AlgorandCoin(
      algoType: json['algoType'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['algoType'] = algoType;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    String saveKey = 'algorandDetails$mnemonic';

    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = AlgorandConfig(
      seedRoot: seedPhraseRoot,
    );
    final keys = await compute(calculateAlgorandKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final userBalanceMicro =
        await getAlgorandClient(algoType).getBalance(address);
    return userBalanceMicro / pow(10, algorandDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'algorandAddressBalance$address${algoType.index}';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      final userBalance = await getUserBalance(address: address);
      await pref.put(key, userBalance);

      return userBalance;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final keyPair = await compute(
      calculateAlgorandKey,
      AlgorandConfig(
        seedRoot: seedPhraseRoot,
        getAlgorandKeys: true,
      ),
    );
    String signature;
    try {
      signature = await getAlgorandClient(algoType).sendPayment(
        account: keyPair,
        recipient: algo_rand.Address.fromAlgorandAddress(
          address: to,
        ),
        amount: algo_rand.Algo.toMicroAlgos(
          double.parse(amount),
        ),
      );
    } on algo_rand.AlgorandException catch (e) {
      throw e.message;
    }

    return signature;
  }

  @override
  validateAddress(String address) {
    algo_rand.Address.fromAlgorandAddress(
      address: address,
    );
  }

  @override
  int decimals() {
    return algorandDecimals;
  }

  @override
  String getExplorer() {
    return blockExplorer;
  }

  @override
  String getDefault() {
    return default_;
  }

  @override
  String getImage() {
    return image;
  }

  @override
  String getName() {
    return name;
  }

  @override
  String getSymbol() {
    return symbol;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0.001;
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }
}

List<AlgorandCoin> getAlgorandBlockchains() {
  List<AlgorandCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.add(
      AlgorandCoin(
        blockExplorer:
            'https://testnet.algoexplorer.io/tx/$blockExplorerPlaceholder',
        symbol: 'ALGO',
        default_: 'Algorand(Testnet)',
        image: 'assets/algorand.png',
        name: 'ALGO',
        algoType: AlgorandTypes.testNet,
        geckoID: 'algorand',
        rampID: 'algorand',
        payScheme: 'algorand',
      ),
    );
  } else {
    blockChains.addAll([
      AlgorandCoin(
        blockExplorer: 'https://algoexplorer.io/tx/$blockExplorerPlaceholder',
        symbol: 'ALGO',
        default_: 'Algorand',
        image: 'assets/algorand.png',
        name: 'ALGO',
        algoType: AlgorandTypes.mainNet,
        geckoID: 'algorand',
        rampID: 'algorand',
        payScheme: 'algorand',
      ),
    ]);
  }
  return blockChains;
}

enum AlgorandTypes {
  mainNet,
  testNet,
}

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

Future calculateAlgorandKey(AlgorandConfig config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  KeyData masterKey =
      await ED25519_HD_KEY.derivePath("m/44'/283'/0'/0'/0'", seedRoot_.seed);

  final account =
      await algo_rand.Account.fromPrivateKey(HEX.encode(masterKey.key));
  if (config.getAlgorandKeys) {
    return account;
  }

  return {
    'address': account.publicAddress,
  };
}

class AlgorandConfig {
  final SeedPhraseRoot seedRoot;
  final bool getAlgorandKeys;

  const AlgorandConfig({
    required this.seedRoot,
    this.getAlgorandKeys = false,
  });
}
