
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/coin.dart';
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

      final cryptoPrice = await getCryptoPrice(useCache: useCache);
      if (useCache) useCache = false;

      final currPrice = cryptoPrice.getPrice(coin.getGeckoId()) ?? 0.0;
      final currChange = cryptoPrice.getChange(coin.getGeckoId()) ?? 0.0;

      Color color = Colors.grey;
      if (currChange > 0) {
        color = green;
      } else if (currChange < 0) {
        color = red;
      }

      state = BlockchainInfo(
        pricewithSym: cryptoPrice.symbol + formatMoney(currPrice, true),
        change: currChange,
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
