// ── Transaction fetcher ───────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/wallet_transaction.dart';

class NanoTransactionFetcher implements TransactionFetcher {
  final String api;
  final String symbol;
  final int decimals;
  final String blockExplorer;

  const NanoTransactionFetcher({
    required this.api,
    required this.symbol,
    required this.decimals,
    required this.blockExplorer,
  });

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    final res = await http.post(
      Uri.parse(api),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'account_history',
        'account': address,
        'count': limit.toString(),
        'reverse': 'false', // newest first
      }),
    );

    final data = jsonDecode(res.body);
    if (data['error'] != null) return [];

    final history = data['history'];
    if (history == null || history is String || (history as List).isEmpty) {
      return [];
    }

    return history.map<WalletTransaction>((e) {
      final isSend = (e['type'] as String) == 'send';
      final counterparty = e['account'] as String;
      final rawAmount = e['amount'] as String;
      final humanAmount = _rawToHuman(rawAmount);
      final ts = DateTime.fromMillisecondsSinceEpoch(
        int.parse(e['local_timestamp'] as String) * 1000,
      );
      final hash = e['hash'] as String;

      return WalletTransaction(
        hash: hash,
        from: isSend ? address : counterparty,
        to: isSend ? counterparty : address,
        amount: humanAmount,
        symbol: symbol,
        decimals: decimals,
        timestamp: ts,
        status: WalletTxStatus.confirmed, // all history blocks are confirmed
        direction: isSend ? WalletTxDirection.sent : WalletTxDirection.received,
        explorerUrl: blockExplorer.replaceFirst(
          blockExplorerPlaceholder,
          hash,
        ),
      );
    }).toList();
  }

  String _rawToHuman(String raw) {
    final value = BigInt.parse(raw);
    final divisor = BigInt.from(10).pow(decimals);
    final whole = value ~/ divisor;
    final remainder = value % divisor;
    if (remainder == BigInt.zero) return whole.toString();
    final fracStr = remainder.toString().padLeft(decimals, '0').trimRight();
    return '$whole.$fracStr';
  }
}
