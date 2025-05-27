//

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';

import '../../extensions/big_int_ext.dart';
import '../../interface/ft_explorer.dart';
import '../../service/wallet_service.dart';
import 'package:wallet_app/coins/multiversx_coin.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../../main.dart';
import '../../model/esdt_balance_model.dart';
import '../../utils/app_config.dart';
import 'package:multiversx_sdk/multiversx.dart' as multiversx;

class ESDTCoin extends MultiversxCoin implements FTExplorer {
  String identifier;
  int mintDecimals;
  ESDTCoin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.rpc,
    required super.name,
    required super.geckoID,
    required this.identifier,
    required this.mintDecimals,
  }) : super(
          rampID: '',
          payScheme: '',
        );

  @override
  Widget? getNFTPage() => null;

  @override
  int decimals() => mintDecimals;

  @override
  String tokenAddress() => identifier;

  factory ESDTCoin.fromJson(Map<String, dynamic> json) {
    return ESDTCoin(
      rpc: json['rpc'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      identifier: json['identifier'],
      image: json['image'],
      name: json['name'],
      geckoID: json['geckoID'],
      mintDecimals: json['mintDecimals'],
    );
  }

  Future<String> _trnsCoin(_TrxCoinParams config) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    multiversx.UserSecretKey signer =
        multiversx.UserSecretKey(HEX.decode(response.privateKey!));
    multiversx.Wallet wallet = multiversx.Wallet(signer);

    await wallet.synchronize(getProxy());

    final amount = config.amount.toBigIntDec(decimals());
    final txHash = await wallet.sendEsdt(
      identifier: identifier,
      provider: getProxy(),
      to: multiversx.Address.fromBech32(config.to),
      amount: multiversx.Balance(amount),
    );

    return txHash.hash;
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final url = '${rpc}address/$address/esdt/$identifier';

    final request = await get(Uri.parse(url));
    final responseBody = request.body;

    if (request.statusCode ~/ 100 == 4 || request.statusCode ~/ 100 == 5) {
      throw Exception(responseBody);
    }

    EsdtBalanceModel esdtBalanceModel =
        EsdtBalanceModel.fromJson(json.decode(responseBody));
    final balance = esdtBalanceModel.data!.tokenData!.balance;

    final base = BigInt.from(10);

    return BigInt.parse(balance) / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'ESDTddressBalance$identifier$rpc$address';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      double fraction = await getUserBalance(address: address);
      await pref.put(key, fraction);

      return fraction;
    } catch (_) {
      return savedBalance;
    }
  }

  @override
  Future<String> transferToken(String amount, String to, {String? memo}) async {
    var sendTransaction = await compute(
      _trnsCoin,
      _TrxCoinParams(
        to: to,
        amount: amount,
      ),
    );

    return sendTransaction;
  }

  @override
  String? get badgeImage => multiversXchains.first.image;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['rpc'] = rpc;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['identifier'] = identifier;
    data['mintDecimals'] = mintDecimals;
    data['geckoID'] = geckoID;
    return data;
  }

  @override
  String savedTransKey() {
    return '$identifier$rpc Details';
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0;
  }

  @override
  String contractExplorer() {
    return getExplorer().replaceFirst(
      '/transactions/$blockExplorerPlaceholder',
      '/tokens/${tokenAddress()}',
    );
  }

  @override
  String getGeckoId() => geckoID;
}

List<ESDTCoin> getESDTCoins() {
  List<ESDTCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.addAll([]);
  } else {
    blockChains.addAll([
      ESDTCoin(
        name: 'AshSwap',
        geckoID: "ashswap",
        symbol: 'ASH',
        default_: 'EGLD',
        blockExplorer:
            'https://explorer.multiversx.com/transactions/$blockExplorerPlaceholder',
        image: 'assets/ashswap.png',
        rpc: 'https://gateway.multiversx.com/',
        identifier: 'ASH-a642d1',
        mintDecimals: 18,
      ),
      ESDTCoin(
        name: 'WrappedEGLD',
        symbol: 'WEGLD',
        default_: 'EGLD',
        blockExplorer:
            'https://explorer.multiversx.com/transactions/$blockExplorerPlaceholder',
        image: 'assets/wEGLD.png',
        rpc: 'https://gateway.multiversx.com/',
        identifier: 'WEGLD-bd4d79',
        mintDecimals: 18,
        geckoID: "wrapped-elrond",
      ),
      ESDTCoin(
        name: 'USDC',
        symbol: 'USDC',
        default_: 'EGLD',
        blockExplorer:
            'https://explorer.multiversx.com/transactions/$blockExplorerPlaceholder',
        image: 'assets/wusd.png',
        rpc: 'https://gateway.multiversx.com/',
        identifier: 'USDC-c76f1f',
        mintDecimals: 6,
        geckoID: 'usd-coin',
      ),
      ESDTCoin(
        name: 'ZoidPay',
        symbol: 'ZPAY',
        default_: 'EGLD',
        blockExplorer:
            'https://explorer.multiversx.com/transactions/$blockExplorerPlaceholder',
        image: 'assets/zpay.png',
        rpc: 'https://gateway.multiversx.com/',
        identifier: 'ZPAY-247875',
        mintDecimals: 18,
        geckoID: "zoid-pay",
      ),
    ]);
  }

  return blockChains;
}

class _TrxCoinParams {
  final String amount;
  final String to;
  const _TrxCoinParams({
    required this.amount,
    required this.to,
  });
}
