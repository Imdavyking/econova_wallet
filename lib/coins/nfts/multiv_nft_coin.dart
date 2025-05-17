// ignore_for_file: constant_identifier_names

import 'package:hex/hex.dart';

import '../../service/wallet_service.dart';
import 'package:wallet_app/coins/multiversx_coin.dart';
import 'package:flutter/foundation.dart';

import '../../main.dart';

import 'package:multiversx_sdk/multiversx.dart' as multiversx;

enum MultivNFTType {
  SemiFungibleESDT,
  NonFungibleESDT,
}

class MultiversxNFTCoin extends MultiversxCoin {
  final String identifier;
  final String ticker;
  final String collection;
  final String description;
  final MultivNFTType tokenType;
  final double balance;
  final int nonce;

  String getIdentifier() {
    return identifier;
  }

  MultiversxNFTCoin({
    required this.identifier,
    required this.ticker,
    required this.description,
    required this.nonce,
    required this.collection,
    required this.balance,
    required String blockExplorer,
    required String symbol,
    required String default_,
    required String image,
    required String rpc,
    required String name,
    required this.tokenType,
  }) : super(
          blockExplorer: blockExplorer,
          symbol: symbol,
          default_: default_,
          image: image,
          rpc: rpc,
          name: name,
          geckoID: '',
          rampID: '',
          payScheme: '',
        );

  factory MultiversxNFTCoin.fromJson(Map<String, dynamic> json) {
    if (json['tokenType'].runtimeType == String) {
      json['tokenType'] = MultivNFTType.values.byName(json['tokenType']);
    }

    return MultiversxNFTCoin(
      ticker: json['ticker'],
      identifier: json['identifier'],
      description: json['description'],
      nonce: json['nonce'],
      rpc: json['rpc'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      balance: json['balance'],
      collection: json['collection'],
      tokenType: json['tokenType'] ?? MultivNFTType.NonFungibleESDT,
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
    data['ticker'] = ticker;
    data['balance'] = balance;
    data['identifier'] = identifier;
    data['description'] = description;
    data['nonce'] = nonce;
    data['collection'] = collection;
    data['tokenType'] = tokenType.name;

    return data;
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    return balance;
  }

  @override
  String getGeckoId() => '';

  Future<String> trnsNFT(_TrxNFTParams config) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    multiversx.UserSecretKey signer =
        multiversx.UserSecretKey(HEX.decode(response.privateKey!));
    multiversx.Wallet wallet = multiversx.Wallet(signer);

    await wallet.synchronize(getProxy());

    BigInt amount = BigInt.from(double.parse(config.amount));

    final txHash = await wallet.sendEsdtNFT(
      collection: collection,
      provider: getProxy(),
      to: multiversx.Address.fromBech32(config.to),
      amount: amount.toInt(),
      nonce: nonce,
    );

    return txHash.hash;
  }

  @override
  Future<String?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    var sendTransaction = await compute(
      trnsNFT,
      _TrxNFTParams(
        to: to,
        amount: amount,
      ),
    );

    return sendTransaction;
  }
}

class _TrxNFTParams {
  final String amount;
  final String to;
  const _TrxNFTParams({
    required this.amount,
    required this.to,
  });
}
