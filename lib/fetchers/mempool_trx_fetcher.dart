// fetchers/mempool_trx_fetcher.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../utils/wallet_transaction.dart';

class MempoolTransactionFetcher implements TransactionFetcher {
  final String apiBase;
  final String symbol;
  final String explorerBase;

  const MempoolTransactionFetcher({
    required this.apiBase,
    required this.symbol,
    required this.explorerBase,
  });

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    final res = await http
        .get(Uri.parse('$apiBase/address/$address/txs'))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Mempool API ${res.statusCode}: ${res.body}');
    }

    final txs = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();

    return txs
        .take(limit)
        .map((tx) => _map(tx, address))
        .whereType<WalletTransaction>()
        .toList();
  }

  WalletTransaction? _map(Map<String, dynamic> tx, String currentAddress) {
    final txid = tx['txid'] as String? ?? '';
    final status = tx['status'] as Map<String, dynamic>? ?? {};
    final confirmed = status['confirmed'] as bool? ?? false;
    final blockTime = status['block_time'] as int?;

    final vins = (tx['vin'] as List? ?? []).cast<Map<String, dynamic>>();
    final vouts = (tx['vout'] as List? ?? []).cast<Map<String, dynamic>>();

    // Determine if sent or received
    final isSent = vins.any((vin) {
      final prevOut = vin['prevout'] as Map<String, dynamic>? ?? {};
      return prevOut['scriptpubkey_address'] == currentAddress;
    });

    // Calculate amount
    int satoshis = 0;
    String from = '';
    String to = '';

    if (isSent) {
      // Sum outputs NOT going back to us (minus change)
      for (final vout in vouts) {
        final addr = vout['scriptpubkey_address'] as String? ?? '';
        if (addr != currentAddress) {
          satoshis += vout['value'] as int? ?? 0;
          to = addr;
        }
      }
      from = currentAddress;
    } else {
      // Sum outputs coming to us
      for (final vout in vouts) {
        final addr = vout['scriptpubkey_address'] as String? ?? '';
        if (addr == currentAddress) {
          satoshis += vout['value'] as int? ?? 0;
        }
      }
      // Sender = first input address
      final firstInput = vins.firstOrNull?['prevout'] as Map<String, dynamic>?;
      from = (firstInput?['scriptpubkey_address'] as String?) ?? '';
      to = currentAddress;
    }

    const dec = 8;
    final amount = (satoshis / pow(10, dec)).toStringAsFixed(dec);

    return WalletTransaction(
      hash: txid,
      from: from,
      to: to,
      amount: amount,
      symbol: symbol,
      decimals: dec,
      timestamp: blockTime != null
          ? DateTime.fromMillisecondsSinceEpoch(blockTime * 1000)
          : DateTime.now(),
      status: confirmed ? WalletTxStatus.confirmed : WalletTxStatus.pending,
      direction: isSent ? WalletTxDirection.sent : WalletTxDirection.received,
      explorerUrl: '$explorerBase$txid',
    );
  }
}
