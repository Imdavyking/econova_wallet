import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../utils/wallet_transaction.dart';

/// Blockfrost API — requires the project_id already embedded in CardanoCoin.
class CardanoTransactionFetcher implements TransactionFetcher {
  final String blockFrostKey;
  final bool isTestnet;

  const CardanoTransactionFetcher({
    required this.blockFrostKey,
    required this.isTestnet,
  });

  String get _api => isTestnet
      ? 'https://cardano-preprod.blockfrost.io/api/v0'
      : 'https://cardano-mainnet.blockfrost.io/api/v0';

  String get _explorerBase => isTestnet
      ? 'https://preprod.cardanoscan.io/transaction/'
      : 'https://cardanoscan.io/transaction/';

  Map<String, String> get _headers => {'project_id': blockFrostKey};

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    final listUri = Uri.parse(
      '$_api/addresses/$address/transactions'
      '?count=$limit&order=desc',
    );
    final listRes = await http
        .get(listUri, headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (listRes.statusCode == 404) return [];
    if (listRes.statusCode ~/ 100 != 2) {
      throw Exception('Blockfrost ${listRes.statusCode}: ${listRes.body}');
    }

    final txList = jsonDecode(listRes.body) as List;
    final hashes = txList
        .whereType<Map<String, dynamic>>()
        .map((e) => e['tx_hash'] as String? ?? '')
        .where((h) => h.isNotEmpty)
        .toList();

    // Fetch all txs in parallel instead of sequentially
    final results = await Future.wait(
      hashes.map((hash) => _fetchTx(hash, address)),
    );

    return results.whereType<WalletTransaction>().toList();
  }

  Future<WalletTransaction?> _fetchTx(String hash, String address) async {
    // Fetch tx detail and UTxOs in parallel
    final txFut = http.get(
      Uri.parse('$_api/txs/$hash'),
      headers: _headers,
    );
    final utxoFut = http.get(
      Uri.parse('$_api/txs/$hash/utxos'),
      headers: _headers,
    );

    final responses = await Future.wait([txFut, utxoFut])
        .timeout(const Duration(seconds: 10));

    final txRes = responses[0];
    final utxoRes = responses[1];

    if (txRes.statusCode ~/ 100 != 2 || utxoRes.statusCode ~/ 100 != 2) {
      return null;
    }

    final txBody = jsonDecode(txRes.body) as Map<String, dynamic>;
    final utxoBody = jsonDecode(utxoRes.body) as Map<String, dynamic>;

    final inputs =
        (utxoBody['inputs'] as List? ?? []).whereType<Map<String, dynamic>>();
    final outputs =
        (utxoBody['outputs'] as List? ?? []).whereType<Map<String, dynamic>>();

    // Determine direction
    final isSender = inputs.any((i) => i['address'] == address);
    final direction =
        isSender ? WalletTxDirection.sent : WalletTxDirection.received;

    // Calculate lovelace amount relevant to this address
    int lovelace = 0;
    if (isSender) {
      // Amount sent = outputs NOT going back to sender (change)
      for (final out in outputs) {
        if (out['address'] != address) {
          final amounts =
              (out['amount'] as List? ?? []).whereType<Map<String, dynamic>>();
          for (final a in amounts) {
            if (a['unit'] == 'lovelace') {
              lovelace += int.tryParse(a['quantity'] as String? ?? '0') ?? 0;
            }
          }
        }
      }
    } else {
      // Amount received = outputs going to this address
      for (final out in outputs) {
        if (out['address'] == address) {
          final amounts =
              (out['amount'] as List? ?? []).whereType<Map<String, dynamic>>();
          for (final a in amounts) {
            if (a['unit'] == 'lovelace') {
              lovelace += int.tryParse(a['quantity'] as String? ?? '0') ?? 0;
            }
          }
        }
      }
    }

    if (lovelace == 0) return null;

    // Sender address — use first input address
    final senderAddress =
        inputs.isNotEmpty ? inputs.first['address'] as String? ?? '' : '';
    // Recipient — first output not going back to sender
    final recipientAddress = outputs.firstWhere(
          (o) => o['address'] != senderAddress,
          orElse: () => outputs.isNotEmpty ? outputs.first : {},
        )['address'] as String? ??
        '';

    const dec = 6;
    final amount = (lovelace / pow(10, dec)).toStringAsFixed(dec);

    final blockTime = txBody['block_time'] as int? ?? 0;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(blockTime * 1000);

    return WalletTransaction(
      hash: hash,
      from: senderAddress,
      to: recipientAddress,
      amount: amount,
      symbol: 'ADA',
      decimals: dec,
      timestamp: timestamp,
      status: WalletTxStatus.confirmed,
      direction: direction,
      explorerUrl: '$_explorerBase$hash',
    );
  }
}
