import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/coin.dart';
import '../utils/app_config.dart';
import '../utils/format_money.dart';
import '../utils/rpc_urls.dart';

// ── Typed data classes ────────────────────────────────────────────────────────

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

class TokenTransaction {
  final String from;
  final String to;
  final String transactionHash;
  final String time;
  final num value;
  final int decimal;

  const TokenTransaction({
    required this.from,
    required this.to,
    required this.transactionHash,
    required this.time,
    required this.value,
    required this.decimal,
  });

  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      transactionHash: json['transactionHash'] as String? ?? '',
      time: json['time'] as String? ?? '',
      value: json['value'] as num? ?? 0,
      decimal: json['decimal'] as int? ?? 18,
    );
  }

  double get tokenAmount => value / pow(10, decimal);
}

class TransactionState {
  final List<TokenTransaction> transactions;
  final String currentUser;

  const TransactionState({
    required this.transactions,
    required this.currentUser,
  });
}

// ── State notifiers ───────────────────────────────────────────────────────────

class BlockchainInfoData extends StateNotifier<BlockchainInfo?> {
  bool _useCache = true;
  final Coin coin;

  BlockchainInfoData({required this.coin}) : super(null);

  Future<void> getBlockchainPrice() async {
    try {
      if (coin.getGeckoId().isEmpty) return;

      final cryptoPrice = await getCryptoPrice(useCache: _useCache);
      if (_useCache) _useCache = false;

      final currPrice = cryptoPrice.getPrice(coin.getGeckoId()) ?? 0.0;
      final currChange = cryptoPrice.getChange(coin.getGeckoId()) ?? 0.0;

      Color color = Colors.grey;
      if (currChange > 0) color = green;
      if (currChange < 0) color = red;

      state = BlockchainInfo(
        pricewithSym: cryptoPrice.symbol + formatMoney(currPrice, true),
        change: currChange,
        changeSign: currChange > 0 ? '+' : '',
        color: color,
      );
    } catch (_) {}
  }
}

class TransactionData extends StateNotifier<TransactionState?> {
  final Coin coin;

  TransactionData({required this.coin}) : super(null);

  Future<void> getTokenTransactions() async {
    try {
      final raw = await coin.getTransactions();
      final rawList = raw['trx'] as List? ?? [];
      final currentUser = raw['currentUser'] as String? ?? '';

      final transactions = rawList
          .whereType<Map<String, dynamic>>()
          .map(TokenTransaction.fromJson)
          .toList();

      state = TransactionState(
        transactions: transactions,
        currentUser: currentUser,
      );
    } catch (_) {}
  }
}

class TokenBalance extends StateNotifier<double?> {
  bool _useCache = true;
  final Coin coin;

  TokenBalance({required this.coin}) : super(null);

  Future<void> getBlockchainBalance() async {
    try {
      state = await coin.getBalance(_useCache);
      if (_useCache) _useCache = false;
    } catch (_) {}
  }
}
