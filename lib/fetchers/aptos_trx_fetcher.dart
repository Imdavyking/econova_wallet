import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../utils/wallet_transaction.dart';

/// Aptos REST API — official, free, no key required.
class AptosTransactionFetcher implements TransactionFetcher {
  final String rpcUrl;
  final bool isTestnet;

  const AptosTransactionFetcher({
    required this.rpcUrl,
    this.isTestnet = false,
  });

  String get _explorerBase => isTestnet
      ? 'https://explorer.aptoslabs.com/txn/'
      : 'https://explorer.aptoslabs.com/txn/';

  String _explorerUrl(String hash) =>
      '$_explorerBase$hash?network=${isTestnet ? 'devnet' : 'mainnet'}';

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    final uri = Uri.parse(
      '$rpcUrl/accounts/$address/transactions?limit=$limit',
    );

    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 404) return []; // account not found / no txs
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Aptos API ${res.statusCode}: ${res.body}');
    }

    final list = jsonDecode(res.body) as List;

    return list
        .whereType<Map<String, dynamic>>()
        .map((tx) => _map(tx, address))
        .whereType<WalletTransaction>()
        .toList()
        .reversed // newest first (Aptos returns oldest first)
        .toList();
  }

  WalletTransaction? _map(Map<String, dynamic> tx, String currentAddress) {
    final type = tx['type'] as String? ?? '';

    // Only handle user transactions
    if (type != 'user_transaction') return null;

    final hash = tx['hash'] as String? ?? '';
    final sender = tx['sender'] as String? ?? '';
    final success = tx['success'] as bool? ?? false;
    final timestampMicros = int.tryParse(tx['timestamp'] as String? ?? '0') ?? 0;
    final timestamp = DateTime.fromMicrosecondsSinceEpoch(timestampMicros);

    // Parse payload for coin transfer
    final payload = tx['payload'] as Map<String, dynamic>? ?? {};
    final funcName = payload['function'] as String? ?? '';

    // Aptos coin transfer function
    if (!funcName.contains('::coin::transfer') &&
        !funcName.contains('::aptos_account::transfer')) {
      return null; // skip contract interactions etc.
    }

    final args = (payload['arguments'] as List?) ?? [];
    final recipient = args.isNotEmpty ? args[0] as String? ?? '' : '';
    final rawAmount = args.length > 1
        ? int.tryParse(args[1].toString()) ?? 0
        : 0;

    // Determine coin type from type_arguments
    final typeArgs = (payload['type_arguments'] as List?) ?? [];
    final coinType = typeArgs.isNotEmpty
        ? typeArgs[0] as String? ?? '0x1::aptos_coin::AptosCoin'
        : '0x1::aptos_coin::AptosCoin';
    final isAptos = coinType.contains('aptos_coin::AptosCoin');

    const dec = 8;
    final amount = (rawAmount / pow(10, dec)).toStringAsFixed(dec);

    return WalletTransaction(
      hash: hash,
      from: sender,
      to: recipient,
      amount: amount,
      symbol: isAptos ? 'APT' : coinType.split('::').last,
      decimals: dec,
      timestamp: timestamp,
      status: success ? WalletTxStatus.confirmed : WalletTxStatus.failed,
      direction: sender == currentAddress
          ? WalletTxDirection.sent
          : WalletTxDirection.received,
      explorerUrl: _explorerUrl(hash),
    );
  }
}