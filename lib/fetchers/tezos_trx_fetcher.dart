import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../coins/tezos_coin.dart';
import '../utils/wallet_transaction.dart';

/// TzKT API — free, no key required. Cleanest API of any chain.
class TezosTransactionFetcher implements TransactionFetcher {
  final TezosNetworkType networkType;

  const TezosTransactionFetcher({required this.networkType});

  String get _api => networkType == TezosNetworkType.mainNet
      ? 'https://api.tzkt.io'
      : 'https://api.ghostnet.tzkt.io';

  String get _explorerBase => networkType == TezosNetworkType.mainNet
      ? 'https://tzkt.io/'
      : 'https://ghostnet.tzkt.io/';

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    // type=transaction filters out delegations, originations etc.
    final uri = Uri.parse(
      '$_api/v1/accounts/$address/operations'
      '?type=transaction&limit=$limit&sort.desc=id',
    );

    final res = await http.get(uri).timeout(const Duration(seconds: 15));

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('TzKT ${res.statusCode}: ${res.body}');
    }

    final list = jsonDecode(res.body) as List;

    return list
        .whereType<Map<String, dynamic>>()
        .map((tx) => _map(tx, address))
        .whereType<WalletTransaction>()
        .toList();
  }

  WalletTransaction? _map(Map<String, dynamic> tx, String currentAddress) {
    final hash = tx['hash'] as String? ?? '';
    final sender = (tx['sender'] as Map?)?['address'] as String? ?? '';
    final target = (tx['target'] as Map?)?['address'] as String? ?? '';
    final mutez = tx['amount'] as int? ?? 0;
    final status = tx['status'] as String? ?? '';
    final timestamp =
        DateTime.tryParse(tx['timestamp'] as String? ?? '') ?? DateTime.now();

    // Skip internal/failed transactions with 0 amount
    if (mutez == 0 && status != 'applied') return null;

    const dec = 6;
    final amount = (mutez / pow(10, dec)).toStringAsFixed(dec);

    return WalletTransaction(
      hash: hash,
      from: sender,
      to: target,
      amount: amount,
      symbol: 'XTZ',
      decimals: dec,
      timestamp: timestamp,
      status: status == 'applied'
          ? WalletTxStatus.confirmed
          : WalletTxStatus.failed,
      direction: sender == currentAddress
          ? WalletTxDirection.sent
          : WalletTxDirection.received,
      explorerUrl: '$_explorerBase$hash',
    );
  }
}
