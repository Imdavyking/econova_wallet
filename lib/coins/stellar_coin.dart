// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import '../service/wallet_service.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stellar;

import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';

const stellarDecimals = 6;

class StellarCoin extends Coin {
  stellar.Network cluster;
  stellar.StellarSDK sdk;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;

  @override
  Future<String?> resolveAddress(String address) async {
    stellar.FederationResponse response =
        await stellar.Federation.resolveStellarAddress(address);
    return response.accountId;
  }

  @override
  String getExplorer() {
    return blockExplorer;
  }

  @override
  bool requireMemo() => true;

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

  StellarCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.sdk,
    required this.cluster,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory StellarCoin.fromJson(Map<String, dynamic> json) {
    return StellarCoin(
      sdk: json['sdk'],
      cluster: json['cluster'],
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
    data['cluster'] = cluster;
    data['sdk'] = sdk;
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
    final saveKey = 'stellarDetail${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = StellarArgs(mnemonic: mnemonic);
    final keys = await compute(calculateStellarKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    stellar.AccountResponse account = await sdk.accounts.account(address);
    List balances = account.balances!;

    for (stellar.Balance balance in balances) {
      if (balance.assetType == stellar.Asset.TYPE_NATIVE) {
        return double.parse(balance.balance!);
      }
    }
    return 0;
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();
    final key =
        'stellarAddressBalance$address${bytesToHex(cluster.networkId!)}';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      double balanceInStellar = await getUserBalance(address: address);
      await pref.put(key, balanceInStellar);
      return balanceInStellar;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  Future<String?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final stellarDetails = await importData(data);
    stellar.KeyPair senderKeyPair =
        stellar.KeyPair.fromSecretSeed(stellarDetails.privateKey!);

    stellar.AccountResponse sender =
        await sdk.accounts.account(senderKeyPair.accountId);
    stellar.Operation operation;
    if (await isActiveStellarAccount(to)) {
      operation = stellar.PaymentOperationBuilder(
        to,
        stellar.Asset.NATIVE,
        amount,
      ).build();
    } else {
      operation = stellar.CreateAccountOperationBuilder(
        to,
        amount,
      ).build();
    }

    stellar.TransactionBuilder transactionBuilder =
        stellar.TransactionBuilder(sender).addOperation(operation);

    if (memo != null) {
      transactionBuilder.addMemo(stellar.Memo.text(memo));
    }

    stellar.Transaction transaction = transactionBuilder.build();

    transaction.sign(
      senderKeyPair,
      cluster,
    );

    stellar.SubmitTransactionResponse response =
        await sdk.submitTransaction(transaction);

    if (response.success) {
      return response.hash;
    }
    throw Exception('could not send coin');
  }

  @override
  validateAddress(String address) {
    stellar.KeyPair.fromAccountId(address);
  }

  Future<double> getStellarGas(
      String destinationAddress, String stellarToSend) async {
    try {
      final data = WalletService.getActiveKey(walletImportType)!.data;
      AccountData getStellarDetails = await importData(data);

      stellar.KeyPair senderKeyPair =
          stellar.KeyPair.fromSecretSeed(getStellarDetails.privateKey!);
      stellar.AccountResponse sender =
          await sdk.accounts.account(senderKeyPair.accountId);
      stellar.Operation operation;
      if (await isActiveStellarAccount(destinationAddress)) {
        operation = stellar.PaymentOperationBuilder(
          destinationAddress,
          stellar.Asset.NATIVE,
          stellarToSend,
        ).build();
      } else {
        operation = stellar.CreateAccountOperationBuilder(
          destinationAddress,
          stellarToSend,
        ).build();
      }

      stellar.Transaction transaction =
          stellar.TransactionBuilder(sender).addOperation(operation).build();

      return transaction.fee! / pow(10, stellarDecimals);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print(stackTrace);
      }
      return 0;
    }
  }

  @override
  int decimals() {
    return stellarDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return await getStellarGas(to, amount);
  }

  Future<bool> isActiveStellarAccount(String address) async {
    try {
      stellar.KeyPair senderKeyPair = stellar.KeyPair.fromAccountId(address);
      await sdk.accounts.account(senderKeyPair.accountId);
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print(stackTrace);
      }
      return false;
    }
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/transactions/', '/accounts/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<StellarCoin> getStellarBlockChains() {
  List<StellarCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      StellarCoin(
        name: 'Stellar(Testnet)',
        symbol: 'XLM',
        default_: 'XLM',
        blockExplorer:
            'https://testnet.stellarchain.io/transactions/$blockExplorerPlaceholder',
        image: 'assets/stellar.png',
        sdk: stellar.StellarSDK.TESTNET,
        cluster: stellar.Network.TESTNET,
        geckoID: 'stellar',
        payScheme: 'stellar',
        rampID: "XLM_XLM",
      ),
    );
  } else {
    blockChains.addAll([
      StellarCoin(
        name: 'Stellar',
        symbol: 'XLM',
        default_: 'XLM',
        blockExplorer:
            'https://stellarchain.io/transactions/$blockExplorerPlaceholder',
        image: 'assets/stellar.png',
        sdk: stellar.StellarSDK.PUBLIC,
        cluster: stellar.Network.PUBLIC,
        geckoID: 'stellar',
        payScheme: 'stellar',
        rampID: "XLM_XLM",
      ),
    ]);
  }
  return blockChains;
}

class StellarArgs {
  final String mnemonic;

  const StellarArgs({
    required this.mnemonic,
  });
}

Future<Map> calculateStellarKey(StellarArgs config) async {
  final wallet = await stellar.Wallet.from(config.mnemonic);
  final userWalletAddress = await wallet.getKeyPair(index: 0);
  return {
    'address': userWalletAddress.accountId,
    'privateKey': userWalletAddress.secretSeed,
  };
}
