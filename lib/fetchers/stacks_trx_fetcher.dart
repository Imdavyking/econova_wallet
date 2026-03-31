import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../utils/wallet_transaction.dart';

/// Hiro API — free, no key required.
class StacksTransactionFetcher implements TransactionFetcher {
  final bool isTestnet;

  const StacksTransactionFetcher({required this.isTestnet});

  String get _base =>
      isTestnet ? 'https://api.testnet.hiro.so' : 'https://api.hiro.so';

  String get _explorerBase => isTestnet
      ? 'https://explorer.hiro.so/txid/'
      : 'https://explorer.hiro.so/txid/';

  String _explorerUrl(String hash) =>
      '$_explorerBase$hash?chain=${isTestnet ? 'testnet' : 'mainnet'}';

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    final uri = Uri.parse(
      '$_base/extended/v1/address/$address/transactions'
      '?limit=$limit&offset=0',
    );

    final res = await http.get(uri, headers: {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 15));

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Stacks API ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final results =
        (body['results'] as List? ?? []).whereType<Map<String, dynamic>>();

    return results
        .map((tx) => _map(tx, address))
        .whereType<WalletTransaction>()
        .toList();
  }

  WalletTransaction? _map(Map<String, dynamic> tx, String currentAddress) {
    final type = tx['tx_type'] as String? ?? '';
    if (type != 'token_transfer') return null; // skip contract calls etc.

    final hash = tx['tx_id'] as String? ?? '';
    final sender = tx['sender_address'] as String? ?? '';
    final transfer = tx['token_transfer'] as Map<String, dynamic>? ?? {};
    final recipient = transfer['recipient_address'] as String? ?? '';
    final microStx = int.tryParse(transfer['amount'] as String? ?? '0') ?? 0;
    final memo = _decodeMemo(transfer['memo'] as String?);
    final burnBlock = tx['burn_block_time'] as int? ?? 0;
    final status = tx['tx_status'] as String? ?? '';

    const dec = 6;
    final amount = (microStx / pow(10, dec)).toStringAsFixed(dec);

    return WalletTransaction(
      hash: hash,
      from: sender,
      to: recipient,
      amount: amount,
      symbol: 'STX',
      decimals: dec,
      timestamp: DateTime.fromMillisecondsSinceEpoch(burnBlock * 1000),
      status: _parseStatus(status),
      direction: sender == currentAddress
          ? WalletTxDirection.sent
          : WalletTxDirection.received,
      memo: memo,
      explorerUrl: _explorerUrl(hash),
    );
  }

  WalletTxStatus _parseStatus(String s) {
    switch (s) {
      case 'success':
        return WalletTxStatus.confirmed;
      case 'pending':
        return WalletTxStatus.pending;
      default:
        return WalletTxStatus.failed;
    }
  }

  /// Stacks memos are hex-encoded null-padded 34-byte strings.
  String? _decodeMemo(String? hex) {
    if (hex == null || hex.isEmpty || hex == '0x') return null;
    try {
      final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
      final bytes = List.generate(
        clean.length ~/ 2,
        (i) => int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16),
      );
      final decoded = utf8.decode(bytes, allowMalformed: true);
      final trimmed = decoded.replaceAll('\x00', '').trim();
      return trimmed.isEmpty ? null : trimmed;
    } catch (_) {
      return null;
    }
  }
}
