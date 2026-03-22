import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/wallet_transaction.dart';

/// Stellar Horizon API — official, free, no key required.
class StellarTransactionFetcher implements TransactionFetcher {
  final bool isTestnet;

  const StellarTransactionFetcher({required this.isTestnet});

  String get _horizon => isTestnet
      ? 'https://horizon-testnet.stellar.org'
      : 'https://horizon.stellar.org';

  String get _explorerBase => isTestnet
      ? 'https://testnet.stellarchain.io/transactions/'
      : 'https://stellarchain.io/transactions/';

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    // Fetch payments (more granular than transactions for XLM transfers)
    final uri = Uri.parse(
      '$_horizon/accounts/$address/payments'
      '?limit=$limit&order=desc',
    );

    final res = await http.get(uri, headers: {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 15));

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Horizon ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final records = ((body['_embedded'] as Map?)?['records'] as List? ?? [])
        .whereType<Map<String, dynamic>>();

    // Fetch memos for each tx in parallel (Horizon payments don't include memo)
    final List<WalletTransaction> result = [];
    for (final record in records) {
      final tx = await _map(record, address);
      if (tx != null) result.add(tx);
    }
    return result;
  }

  Future<WalletTransaction?> _map(
      Map<String, dynamic> record, String currentAddress) async {
    final type = record['type'] as String? ?? '';

    // Only handle native XLM payments and account_created (first receive)
    if (type != 'payment' && type != 'create_account') return null;

    final isPayment = type == 'payment';

    if (isPayment) {
      final asset = record['asset_type'] as String? ?? '';
      if (asset != 'native') return null; // skip non-XLM for now
    }

    final hash = record['transaction_hash'] as String? ?? '';
    final sender = isPayment
        ? record['from'] as String? ?? ''
        : record['funder'] as String? ?? '';
    final recipient = isPayment
        ? record['to'] as String? ?? ''
        : record['account'] as String? ?? '';
    final rawAmount = isPayment
        ? record['amount'] as String? ?? '0'
        : record['starting_balance'] as String? ?? '0';

    final createdAt = record['created_at'] as String? ?? '';
    final timestamp = DateTime.tryParse(createdAt) ?? DateTime.now();

    // Fetch memo from transaction
    String? memo;
    try {
      final txRes = await http.get(
        Uri.parse('$_horizon/transactions/$hash'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      if (txRes.statusCode ~/ 100 == 2) {
        final txBody = jsonDecode(txRes.body) as Map<String, dynamic>;
        final memoType = txBody['memo_type'] as String? ?? 'none';
        if (memoType != 'none') {
          memo = txBody['memo'] as String?;
        }
      }
    } catch (_) {}

    return WalletTransaction(
      hash: hash,
      from: sender,
      to: recipient,
      amount: rawAmount,
      symbol: 'XLM',
      decimals: 7, // Stellar uses 7 decimal places
      timestamp: timestamp,
      status: WalletTxStatus.confirmed, // Horizon only returns confirmed
      direction: sender == currentAddress
          ? WalletTxDirection.sent
          : WalletTxDirection.received,
      memo: memo,
      explorerUrl: '$_explorerBase$hash',
    );
  }
}
