import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wallet_app/utils/app_config.dart';
import '../utils/rpc_urls.dart';
import '../utils/wallet_transaction.dart';

const _nimiqDecimals = 5;

class NimiqTransactionFetcher implements TransactionFetcher {
  final String rpcUrl;
  final String symbol;

  /// The block-explorer URL template containing [blockExplorerPlaceholder].
  final String explorerUrlTemplate;

  const NimiqTransactionFetcher({
    required this.rpcUrl,
    required this.symbol,
    required this.explorerUrlTemplate,
  });

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    final response = await http
        .post(
          Uri.parse(rpcUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'getTransactionsByAddress',
            'params': [address, limit],
          }),
        )
        .timeout(networkTimeOutDuration);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body.containsKey('error')) {
      final err = body['error'] as Map<String, dynamic>;
      throw Exception(err['message'] ?? 'Nimiq RPC error');
    }

    final txList =
        (body['result'] as Map<String, dynamic>?)?['data'] as List<dynamic>?;

    if (txList == null || txList.isEmpty) return [];

    // Normalise own address for direction detection (strip spaces, uppercase)
    final selfNorm = address.replaceAll(RegExp(r'\s'), '').toUpperCase();

    return txList.map((raw) {
      final tx = raw as Map<String, dynamic>;

      // Field names differ slightly across Nimiq RPC versions
      final hash =
          tx['transactionHash'] as String? ?? tx['hash'] as String? ?? '';
      final from =
          tx['senderAddress'] as String? ?? tx['sender'] as String? ?? '';
      final to =
          tx['recipientAddress'] as String? ?? tx['recipient'] as String? ?? '';
      final valueLuna = (tx['value'] as num? ?? 0).toInt();
      final blockNumber = tx['blockNumber'] as int?;
      final timestampSec = tx['timestamp'] as int?;
      final dataField = tx['data'] as String?;

      // Try to decode the on-chain data field as a UTF-8 memo
      String? memo;
      if (dataField != null && dataField.isNotEmpty && dataField != '0x') {
        try {
          final hex =
              dataField.startsWith('0x') ? dataField.substring(2) : dataField;
          if (hex.isNotEmpty) {
            memo = utf8.decode(_hexToBytes(hex), allowMalformed: true);
          }
        } catch (_) {}
      }

      final fromNorm = from.replaceAll(RegExp(r'\s'), '').toUpperCase();
      final isSent = fromNorm == selfNorm;
      final humanAmount = (valueLuna / 100000).toStringAsFixed(_nimiqDecimals);

      return WalletTransaction(
        hash: hash,
        from: from,
        to: to,
        amount: humanAmount,
        symbol: symbol,
        decimals: _nimiqDecimals,
        timestamp: timestampSec != null
            ? DateTime.fromMillisecondsSinceEpoch(timestampSec * 1000)
            : DateTime.now(),
        status: blockNumber != null
            ? WalletTxStatus.confirmed
            : WalletTxStatus.pending,
        direction: isSent ? WalletTxDirection.sent : WalletTxDirection.received,
        explorerUrl: explorerUrlTemplate.replaceFirst(
          blockExplorerPlaceholder,
          hash,
        ),
        memo: memo,
      );
    }).toList();
  }

  static List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (int i = 0; i + 1 < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }
}
