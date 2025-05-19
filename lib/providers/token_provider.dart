import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';
import '../utils/format_money.dart';
import '../utils/rpc_urls.dart';

class BlockchainInfo {
  final String pricewithSym;
  final double change;
  final String changeSign;
  final Color color;
  const BlockchainInfo({
    required this.pricewithSym,
    required this.change,
    required this.changeSign,
    required this.color,
  });
}

class BlockchainInfoData extends StateNotifier<BlockchainInfo?> {
  bool useCache = true;
  Coin coin;

  BlockchainInfoData({required this.coin}) : super(null);
  Future getBlockchainPrice() async {
    try {
      if (coin.getGeckoId().isEmpty) return;

      final currencyWithSymbol = jsonDecode(currencyJson) as Map;
      final String defaultCurrency = pref.get('defaultCurrency') ?? "USD";

      final String symbol = (currencyWithSymbol[defaultCurrency]['symbol']);

      Map allCryptoPrice = jsonDecode(
        await getCryptoPrice(
          useCache: useCache,
        ),
      ) as Map;

      final Map cryptoMarket = allCryptoPrice[coin.getGeckoId()];

      final deCurrLow = defaultCurrency.toLowerCase();

      final currPrice = cryptoMarket[deCurrLow] as num;

      num? change = cryptoMarket['${deCurrLow}_24h_change'];
      final currChange = change ?? 0;

      Color color = Colors.grey;

      if (currChange > 0) {
        color = green;
      } else if (currChange < 0) {
        color = red;
      }
      state = BlockchainInfo(
        pricewithSym: symbol + formatMoney(currPrice, true),
        change: currChange.toDouble(),
        changeSign: currChange > 0 ? '+' : '',
        color: color,
      );
    } catch (_) {}
  }
}

class TransactionData extends StateNotifier<Map?> {
  bool useCache = true;
  Coin coin;
  TransactionData({required this.coin}) : super(null);

  Future getTokenTransactions() async {
    try {
      state = await coin.getTransactions();
    } catch (_) {}
  }
}

class TokenBalance extends StateNotifier<double?> {
  bool useCache = true;
  Coin coin;
  TokenBalance({required this.coin}) : super(null);

  Future getBlockchainBalance() async {
    try {
      state = await coin.getBalance(useCache);
    } catch (_) {}
  }
}
