import 'package:laksadart/laksadart.dart';

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
// ignore: implementation_imports
import 'package:laksadart/src/data/network/network_info.dart';
import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:flutter/foundation.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';

const zilliqaDecimals = 12;

class ZilliqaCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String rpc;
  String geckoID;
  String rampID;
  String payScheme;
  NetworkInfo network;
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

  ZilliqaCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.rpc,
    required this.geckoID,
    required this.rampID,
    required this.network,
    required this.payScheme,
  });

  factory ZilliqaCoin.fromJson(Map<String, dynamic> json) {
    return ZilliqaCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      rpc: json['rpc'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
      network: NetworkInfo.fromJson(json['network']),
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
    data['geckoID'] = geckoID;
    data['image'] = image;
    data['network'] = network;
    return data;
  }

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'ZilliqaDetailPrivate${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final zilliqa = Zilliqa(network: network);

    final account = zilliqa.wallet.add(privateKey);

    final keys = AccountData(
      address: account!.address!.bech32,
      privateKey: privateKey,
      publicKey: account.publicKey!,
    ).toJson();

    privateKeyMap[privateKey] = keys;

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'ZilliqaCoinDetail${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};
    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = ZilliqaArgs(
      mnemonic: mnemonic,
      network: network,
    );

    final keys = await compute(calculateZilliqaKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();

    final key = 'ZilliqaAddressBalance$address$rpc$name';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      Account acc = Account();
      acc.address = ZilAddress(ZilAddress.toValidAddress(address));
      acc.messenger = Zilliqa(network: network).messenger;

      await acc.updateBalance();

      final base = BigInt.from(10).pow(decimals());

      final balance = BigInt.parse(acc.balance!) / base;

      await pref.put(key, balance);

      return balance;
    } catch (_) {
      return savedBalance;
    }
  }

  @override
  bool get supportKeystore => true;
  @override
  bool get supportPrivateKey => true;

  @override
  Future<String?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final miniZilliqa = amount.toBigIntDec(decimals());
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final zilliqa = Zilliqa(network: network);
    final acc = zilliqa.wallet.add(response.privateKey);

    final txn = zilliqa.transactions.newTx({
      'toAddr': ZilAddress(ZilAddress.toValidAddress(to)).bech32,
      'amount': miniZilliqa,
      'gasPrice': BigInt.from(2000) * BigInt.from(1000000),
      'gasLimit': 50,
      'version': (zilliqa.network!.chainID! << 16) + 1
    });

    final signed = await acc!.signTransaction(txn);
    final sent = await signed.sendTransaction();

    return sent!.transaction.transactionID;
  }

  @override
  validateAddress(String address) {
    ZilAddress.toValidAddress(address);
  }

  @override
  int decimals() {
    return zilliqaDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    // final data = WalletService.getActiveKey(walletImportType)!.data;
    // final response = await importData(data);
    return 0;
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getRampID() => rampID;

  @override
  String getPayScheme() => payScheme;
}

List<ZilliqaCoin> getZilliqaBlockChains() {
  List<ZilliqaCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      ZilliqaCoin(
        name: 'Zilliqa(Testnet)',
        symbol: 'ZIL',
        default_: 'ZIL',
        blockExplorer:
            'https://viewblock.io/zilliqa/tx/$blockExplorerPlaceholder?network=testnet',
        image: 'assets/zilliqa.webp',
        geckoID: "zilliqa",
        rpc: "https://dev-api.zilliqa.com/",
        network: const NetworkInfo(
          chainID: 333,
          networkID: "Developer Testnet",
          nodeProviderUrl: "https://dev-api.zilliqa.com/",
          blockExplorerUrl: "https://viewblock.io/zilliqa?network=testnet",
          blockExplorerNetwork: "testnet",
        ),
        rampID: "ZILLIQA_ZIL",
        payScheme: "zilliqa",
      ),
    );
  } else {
    blockChains.addAll([
      ZilliqaCoin(
        name: 'Zilliqa',
        symbol: 'ZIL',
        default_: 'ZIL',
        blockExplorer:
            'https://viewblock.io/zilliqa/tx/$blockExplorerPlaceholder',
        image: 'assets/zilliqa.webp',
        rpc: "https://api.zilliqa.com/",
        geckoID: "zilliqa",
        network: const NetworkInfo(
          chainID: 1,
          networkID: "Zilliqa Mainnet",
          nodeProviderUrl: "https://api.zilliqa.com/",
          blockExplorerUrl: "https://viewblock.io/zilliqa",
          blockExplorerNetwork: "mainnet",
        ),
        rampID: "ZILLIQA_ZIL",
        payScheme: "zilliqa",
      ),
    ]);
  }

  return blockChains;
}

class ZilliqaArgs {
  final String mnemonic;
  final NetworkInfo network;

  const ZilliqaArgs({
    required this.mnemonic,
    required this.network,
  });
}

Future calculateZilliqaKey(ZilliqaArgs config) async {
  final zilliqa = Zilliqa(network: config.network);

  final account = zilliqa.wallet.importAccountFromMnemonic(config.mnemonic, 0);

  return {
    'address': account!.address!.bech32,
    'privateKey': account.privateKey!,
    'publicKey': account.publicKey!,
  };
}
