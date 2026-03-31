// ─── Waves Transaction Fetcher ────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/wallet_transaction.dart';

class WavesTransactionFetcher implements TransactionFetcher {
  final String nodeUrl;
  final String explorerUrl;
  final String symbol;
  final int coinDecimals;

  const WavesTransactionFetcher({
    required this.nodeUrl,
    required this.explorerUrl,
    required this.symbol,
    required this.coinDecimals,
  });

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    final res = await http.get(
      Uri.parse('$nodeUrl/transactions/address/$address/limit/$limit'),
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('WAVES tx fetch failed: ${res.statusCode}');
    }

    // Response is [[tx, tx, ...]] — outer array is always length 1
    final outer = jsonDecode(res.body) as List;
    final txList = outer[0] as List;

    final result = <WalletTransaction>[];

    for (final tx in txList) {
      final map = tx as Map<String, dynamic>;

      // Only handle transfer transactions (type 4)
      final type = map['type'] as int? ?? 0;
      if (type != 4) continue;

      // Skip non-WAVES asset transfers
      final assetId = map['assetId'];
      if (assetId != null) continue;

      final hash = map['id'] as String? ?? '';
      final from = map['sender'] as String? ?? '';
      final to = map['recipient'] as String? ?? '';
      final amountWavelets = map['amount'] as int? ?? 0;
      final timestampMs = map['timestamp'] as int? ?? 0;

      final amount = (amountWavelets / 1e8).toStringAsFixed(coinDecimals);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        timestampMs,
        isUtc: true,
      );

      final direction =
          from == address ? WalletTxDirection.sent : WalletTxDirection.received;

      final attachment = map['attachment'] as String? ?? '';

      result.add(WalletTransaction(
        hash: hash,
        from: from,
        to: to,
        amount: amount,
        symbol: symbol,
        decimals: coinDecimals,
        timestamp: timestamp,
        status: WalletTxStatus.confirmed, // on-chain = confirmed
        direction: direction,
        explorerUrl: explorerUrl.replaceFirst(blockExplorerPlaceholder, hash),
        memo: attachment.isEmpty ? null : attachment,
      ));
    }

    return result;
  }
}
