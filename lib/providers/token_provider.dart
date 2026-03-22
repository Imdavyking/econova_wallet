import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interface/coin.dart';
import 'package:wallet_app/utils/wallet_transaction.dart';
import '../utils/app_config.dart';
import '../utils/format_money.dart';
import '../utils/rpc_urls.dart';

// ── BlockchainInfo ────────────────────────────────────────────────────────────

class BlockchainInfo {
  final double price;
  final String currencySymbol;
  final String pricewithSym;
  final double change;
  final String changeSign;
  final Color color;

  const BlockchainInfo({
    required this.price,
    required this.currencySymbol,
    required this.pricewithSym,
    required this.change,
    required this.changeSign,
    required this.color,
  });

  String fiatValue(double balance) =>
      '$currencySymbol${formatMoney(balance * price, true)}';
}

// ── TokenTransaction ──────────────────────────────────────────────────────────

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

  /// Bridge: build from a chain-fetched [WalletTransaction].
  factory TokenTransaction.fromWallet(WalletTransaction tx) =>
      TokenTransaction.fromJson(tx.toTokenTransactionJson());

  double get tokenAmount => value / pow(10, decimal);
}

// ── TransactionState ──────────────────────────────────────────────────────────

class TransactionState {
  final List<TokenTransaction> transactions;
  final String currentUser;

  const TransactionState({
    required this.transactions,
    required this.currentUser,
  });
}

// ── BlockchainInfoData ────────────────────────────────────────────────────────

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
        price: currPrice,
        currencySymbol: cryptoPrice.symbol,
        pricewithSym: cryptoPrice.symbol + formatMoney(currPrice, true),
        change: currChange,
        changeSign: currChange > 0 ? '+' : '',
        color: color,
      );
    } catch (_) {}
  }
}

// ── TokenBalance ──────────────────────────────────────────────────────────────

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

// ── TransactionData ───────────────────────────────────────────────────────────

class TransactionData extends StateNotifier<TransactionState?> {
  final Coin coin;

  TransactionData({required this.coin}) : super(null);

  Future<void> getTokenTransactions() async {
    try {
      final address = await coin.getAddress();
      final fetcher = coin.transactionFetcher;

      if (fetcher != null) {
        // ── On-chain indexer path ─────────────────────────────────────────
        final walletTxs = await fetcher.fetch(address: address);
        state = TransactionState(
          transactions: walletTxs.map(TokenTransaction.fromWallet).toList(),
          currentUser: address,
        );
      } else {
        // ── Local store fallback ──────────────────────────────────────────
        final raw = await coin.getTransactions();
        final rawList = raw['trx'] as List? ?? [];
        state = TransactionState(
          transactions: rawList
              .whereType<Map<String, dynamic>>()
              .map(TokenTransaction.fromJson)
              .toList(),
          currentUser: raw['currentUser'] as String? ?? address,
        );
      }
    } catch (_) {}
  }
}
