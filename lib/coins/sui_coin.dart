// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:hex/hex.dart';

import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sui/signers/txn_data_serializers/txn_data_serializer.dart';
import 'package:sui/sui.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';

const suiDecimals = 9;

class SuiCoin extends Coin {
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

  SuiCoin({
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

  factory SuiCoin.fromJson(Map<String, dynamic> json) {
    return SuiCoin(
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
    data['geckoID'] = geckoID;
    data['image'] = image;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;
    return data;
  }

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'suiDetailPrivate${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final keyPair = SuiAccount.fromPrivateKey(
      privateKey,
      SignatureScheme.ED25519,
    );

    final keys = AccountData(
      address: keyPair.getAddress(),
      privateKey: privateKey,
      publicKey: HEX.encode(keyPair.getPublicKey()),
    );

    privateKeyMap[privateKey] = keys.toJson();

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return keys;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'suiCoinDetail${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};
    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = SuiArgs(mnemonic: mnemonic);

    final keys = await compute(calculateSuiKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final suiClient = SuiClient(rpc);

    final resp = await suiClient.provider.getBalance(address);
    final base = BigInt.from(10);
    return resp.totalBalance / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'suiAddressBalance$address$rpc';

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
  Future<String?> resolveAddress(String address) async {
    final client = SuiClient(rpc);
    try {
      return await client.provider.resolveNameServiceAddress(name);
    } catch (e) {
      return null;
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
    final miniSui = amount.toBigIntDec(suiDecimals);
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final keyPair = SuiAccount.fromPrivateKey(
      response.privateKey!,
      SignatureScheme.ED25519,
    );

    final client = SuiClient(rpc, account: keyPair);
    var coins = await client.getCoins(keyPair.getAddress());

    final inputObjectIds = coins.data.map((x) => x.coinObjectId).toList();
    const gasBudget = 10000000;
    final txn = PaySuiTransaction(
      inputObjectIds,
      [to],
      [miniSui.toInt()],
      gasBudget,
    );

    txn.gasBudget = await client.getGasCostEstimation(txn);

    final waitForLocalExecutionTx = await client.paySui(txn);

    return waitForLocalExecutionTx.digest;
  }

  @override
  validateAddress(String address) {
    if (!SuiAccount.isValidAddress(address)) {
      throw Exception('Invalid $symbol address');
    }
  }

  @override
  int decimals() {
    return suiDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final keyPair = SuiAccount.fromPrivateKey(
      response.privateKey!,
      SignatureScheme.ED25519,
    );
    SuiAccount account = keyPair;
    final miniSui = double.parse(amount) * pow(10, suiDecimals);
    final address = await getAddress();
    const gasBudget = 10000000;

    final client = SuiClient(rpc, account: account);
    final coins = await client.getCoins(address);

    final inputObjectIds = coins.data.map((x) => x.coinObjectId).toList();

    final txn = PaySuiTransaction(
      inputObjectIds,
      [to],
      [miniSui.toInt()],
      gasBudget,
    );

    final txFee = await client.getGasCostEstimation(txn);
    return txFee / pow(10, suiDecimals);
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/txblock/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

Future<bool> getFaucetToken(String address) async {
  try {
    final faucet = FaucetClient(Constants.faucetDevAPI);
    await faucet.requestSui(address);
    return true;
  } catch (_) {
    return false;
  }
}

List<SuiCoin> getSuiBlockChains() {
  List<SuiCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      SuiCoin(
        name: 'SUI(Testnet)',
        symbol: 'SUI',
        default_: 'SUI',
        blockExplorer:
            'https://suiexplorer.com/txblock/$blockExplorerPlaceholder?network=devnet',
        image: 'assets/sui.png',
        rpc: Constants.devnetAPI,
        geckoID: "sui",
        payScheme: "sui",
        rampID: '',
      ),
    );
  } else {
    blockChains.addAll([
      SuiCoin(
        name: 'SUI',
        symbol: 'SUI',
        default_: 'SUI',
        blockExplorer:
            'https://suiexplorer.com/txblock/$blockExplorerPlaceholder',
        image: 'assets/sui.png',
        rpc: Constants.mainnetAPI,
        geckoID: "sui",
        payScheme: "sui",
        rampID: '',
      ),
    ]);
  }

  return blockChains;
}

class SuiArgs {
  final String mnemonic;

  const SuiArgs({
    required this.mnemonic,
  });
}

Future calculateSuiKey(SuiArgs config) async {
  final account = SuiAccount.fromMnemonics(
    config.mnemonic,
    SignatureScheme.ED25519,
  );

  return {
    'address': account.getAddress(),
    'privateKey': HEX.encode(account.getSecretKey()),
    'publicKey': HEX.encode(account.getPublicKey()),
  };
}
