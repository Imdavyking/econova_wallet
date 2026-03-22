import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../utils/wallet_transaction.dart';

/// XRPL public RPC — built into the node, no extra service needed.
class XrpTransactionFetcher implements TransactionFetcher {
  final String rpcUrl;
  final bool isTestnet;

  const XrpTransactionFetcher({
    required this.rpcUrl,
    this.isTestnet = false,
  });

  String get _explorerBase => isTestnet
      ? 'https://testnet.xrpl.org/transactions/'
      : 'https://livenet.xrpl.org/transactions/';

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    final res = await http
        .post(
          Uri.parse(rpcUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'method': 'account_tx',
            'params': [
              {
                'account': address,
                'limit': limit,
                'forward': false, // newest first
              }
            ],
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('XRPL RPC ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final result = body['result'] as Map<String, dynamic>? ?? {};
    final txList = (result['transactions'] as List? ?? [])
        .whereType<Map<String, dynamic>>();

    return txList
        .map((entry) => _map(entry, address))
        .whereType<WalletTransaction>()
        .toList();
  }

  WalletTransaction? _map(Map<String, dynamic> entry, String currentAddress) {
    final tx = entry['tx'] as Map<String, dynamic>? ?? {};
    final meta = entry['meta'] as Map<String, dynamic>? ?? {};

    // Only handle Payment transactions
    if (tx['TransactionType'] != 'Payment') return null;

    // Skip IOU / token payments (Amount is a Map, not a String for XRP drops)
    final rawAmount = tx['Amount'];
    if (rawAmount is! String) return null;

    final hash = tx['hash'] as String? ?? '';
    final sender = tx['Account'] as String? ?? '';
    final recipient = tx['Destination'] as String? ?? '';
    final drops = int.tryParse(rawAmount) ?? 0;
    final deliveredDrops = meta['delivered_amount'];
    final actualDrops = deliveredDrops is String
        ? int.tryParse(deliveredDrops) ?? drops
        : drops;

    final destinationTag = tx['DestinationTag'] as int?;
    final date = tx['date'] as int?; // Ripple epoch: seconds since 2000-01-01
    final txResult = meta['TransactionResult'] as String? ?? '';

    const dec = 6;
    final amount = (actualDrops / pow(10, dec)).toStringAsFixed(dec);

    // Convert Ripple epoch to Unix timestamp
    final timestamp = date != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (date + 946684800) * 1000, // add seconds between 1970 and 2000
          )
        : DateTime.now();

    return WalletTransaction(
      hash: hash,
      from: sender,
      to: recipient,
      amount: amount,
      symbol: 'XRP',
      decimals: dec,
      timestamp: timestamp,
      status: txResult == 'tesSUCCESS'
          ? WalletTxStatus.confirmed
          : WalletTxStatus.failed,
      direction: sender == currentAddress
          ? WalletTxDirection.sent
          : WalletTxDirection.received,
      memo: destinationTag?.toString(),
      explorerUrl: '$_explorerBase$hash',
    );
  }
}