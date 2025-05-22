// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';

import 'package:aptos/aptos.dart';
import 'package:aptos/coin_client.dart';
import 'package:aptos/constants.dart';
import 'package:aptos/faucet_client.dart';
import 'package:flutter/foundation.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:wallet_app/service/wallet_service.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';

const aptosDecimals = 8;

class AptosCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String rpc;
  String geckoID;
  String rampID;
  String payScheme;

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/txn/', '/account/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;

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

  AptosCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.rpc,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory AptosCoin.fromJson(Map<String, dynamic> json) {
    return AptosCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      rpc: json['rpc'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rpc'] = rpc;
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
    final saveKey = 'aptosCoinDetail${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final keys = await compute(
      calculateAptosKey,
      AptosArgs(
        mnemonic: mnemonic,
      ),
    );
    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final aptosClient = AptosClient(rpc, enableDebugLog: kDebugMode);
    final coinClient = CoinClient(aptosClient);

    var resp = await coinClient.checkBalance(address);

    return resp / BigInt.from(10).pow(aptosDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();

    final key = 'aptosAddressBalance$address$rpc';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      final balance = await getUserBalance(address: address);
      await pref.put(key, balance);

      return balance;
    } catch (_) {
      return savedBalance;
    }
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final miniAptostoSend = amount.toBigIntDec(decimals());
    final data = WalletService.getActiveKey(walletImportType)!.data;

    final response = await importData(data);
    final privateKey = response.privateKey;
    final keyPair = AptosAccount.fromPrivateKey(privateKey!);

    final aptosClient = AptosClient(rpc, enableDebugLog: kDebugMode);
    final coinClient = CoinClient(aptosClient);

    return await coinClient.transfer(
      keyPair,
      to,
      miniAptostoSend,
      createReceiverIfMissing: true,
    );
  }

  @override
  validateAddress(String address) {
    if (!RegExp(r"^0x[A-Fa-f0-9]{64}$").hasMatch(address)) {
      throw Exception('Invalid $symbol address');
    }
  }

  @override
  int decimals() {
    return aptosDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final aptosClient = AptosClient(rpc, enableDebugLog: kDebugMode);
    final coinClient = CoinClient(aptosClient);

    bool accountExists = false;
    try {
      accountExists = await coinClient.aptosClient.accountExist(to);
    } catch (_) {}

    switch (rpc) {
      case Constants.devnetAPI:
        if (accountExists) {
          return 0.000005;
        } else {
          return 0.001009;
        }
      case Constants.mainnetAPI:
        if (accountExists) {
          return 0.00160416;
        } else {
          return 0.00532224;
        }
      case Constants.testnetAPI:
        if (accountExists) {
          return 0.0000075;
        } else {
          return 0.0010185;
        }
      default:
        return 0.0;
    }
  }
}

Future<bool> getFaucetToken(String address) async {
  try {
    final faucet = FaucetClient.fromClient(
      Constants.faucetDevAPI,
      AptosClient(Constants.devnetAPI),
    );
    final amountToFund = 10 * pow(10, aptosDecimals);
    await faucet.fundAccount(address, amountToFund.toString());
    return true;
  } catch (_) {
    return false;
  }
}

List<AptosCoin> getAptosBlockchain() {
  List<AptosCoin> blockChains = [];
  if (enableTestNet) {
    // blockChains.add({
    //   'name': 'Aptos(Testnet)',
    //   'symbol': 'APT',
    //   'default': 'APT',
    //   'blockExplorer':
    //       'https://explorer.aptoslabs.com/txn/$blockExplorerPlaceholder?network=devnet',
    //   'image': 'assets/aptos.png',
    //   'rpc': Constants.devnetAPI,
    // });
    blockChains.addAll([
      AptosCoin(
        blockExplorer:
            'https://explorer.aptoslabs.com/txn/$blockExplorerPlaceholder?network=devnet',
        symbol: 'APT',
        default_: 'APT',
        image: 'assets/aptos.png',
        name: 'Aptos(Testnet)',
        rpc: Constants.devnetAPI,
        geckoID: 'aptos',
        rampID: 'aptos',
        payScheme: 'aptos',
      )
    ]);
  } else {
    blockChains.addAll([
      AptosCoin(
        blockExplorer:
            'https://explorer.aptoslabs.com/txn/$blockExplorerPlaceholder?network=mainnet',
        symbol: 'APT',
        default_: 'APT',
        image: 'assets/aptos.png',
        name: 'Aptos',
        rpc: Constants.mainnetAPI,
        geckoID: 'aptos',
        rampID: 'aptos',
        payScheme: 'aptos',
      )
    ]);
  }

  return blockChains;
}

class AptosArgs {
  final String mnemonic;

  const AptosArgs({
    required this.mnemonic,
  });
}

Future calculateAptosKey(AptosArgs config) async {
  final account = AptosAccount.generateAccount(
    config.mnemonic,
  );

  return {
    'privateKey': HEX.encode(account.signingKey.privateKey.bytes),
    'address': account.address,
  };
}
