import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../coins/algorand_coin.dart';
import '../utils/wallet_transaction.dart';

/// Fetches Algorand transactions from Nodely free indexer (no API key required).
/// Supports: pay (ALGO), axfer (ASA token transfer).
class AlgorandTransactionFetcher implements TransactionFetcher {
  final AlgorandTypes algoType;
  final String symbol;
  final String explorerBase;

  const AlgorandTransactionFetcher({
    required this.algoType,
    this.symbol = 'ALGO',
    this.explorerBase = 'https://algoexplorer.io/tx/',
  });

  String get _indexerBase => algoType == AlgorandTypes.mainNet
      ? 'https://mainnet-idx.4160.nodely.dev'
      : 'https://testnet-idx.4160.nodely.dev';

  @override
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  }) async {
    final uri = Uri.parse(
      '$_indexerBase/v2/accounts/$address/transactions'
      '?limit=$limit&order=desc',
    );

    final res = await http.get(uri,
        headers: {'X-Algo-API-Token': ''}).timeout(const Duration(seconds: 15));

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Algorand indexer ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final txList =
        (body['transactions'] as List? ?? []).whereType<Map<String, dynamic>>();

    return txList
        .map((tx) => _map(tx, address))
        .whereType<WalletTransaction>()
        .toList();
  }

  WalletTransaction? _map(Map<String, dynamic> tx, String currentAddress) {
    switch (tx['tx-type'] as String? ?? '') {
      case 'pay':
        return _mapPay(tx, currentAddress);
      case 'axfer':
        return _mapAxfer(tx, currentAddress);
      default:
        return null;
    }
  }

  WalletTransaction? _mapPay(Map<String, dynamic> tx, String currentAddress) {
    final pay = tx['payment-transaction'] as Map<String, dynamic>?;
    if (pay == null) return null;

    const dec = 6;
    final microAlgos = pay['amount'] as int? ?? 0;
    final hash = tx['id'] as String? ?? '';
    final from = tx['sender'] as String? ?? '';
    final to = pay['receiver'] as String? ?? '';
    final roundTime = tx['round-time'] as int? ?? 0;

    return WalletTransaction(
      hash: hash,
      from: from,
      to: to,
      amount: (microAlgos / pow(10, dec)).toStringAsFixed(dec),
      symbol: symbol,
      decimals: dec,
      timestamp: DateTime.fromMillisecondsSinceEpoch(roundTime * 1000),
      status: WalletTxStatus.confirmed,
      direction: from == currentAddress
          ? WalletTxDirection.sent
          : WalletTxDirection.received,
      memo: _decodeNote(tx['note'] as String?),
      explorerUrl: '$explorerBase$hash',
    );
  }

  WalletTransaction? _mapAxfer(Map<String, dynamic> tx, String currentAddress) {
    final axfer = tx['asset-transfer-transaction'] as Map<String, dynamic>?;
    if (axfer == null) return null;

    const dec = 6; // ASA decimals ideally fetched from asset info endpoint
    final assetId = axfer['asset-id'] as int? ?? 0;
    final rawAmount = axfer['amount'] as int? ?? 0;
    final hash = tx['id'] as String? ?? '';
    final from = tx['sender'] as String? ?? '';
    final to = axfer['receiver'] as String? ?? '';
    final roundTime = tx['round-time'] as int? ?? 0;

    return WalletTransaction(
      hash: hash,
      from: from,
      to: to,
      amount: (rawAmount / pow(10, dec)).toStringAsFixed(dec),
      symbol: 'ASA-$assetId',
      decimals: dec,
      timestamp: DateTime.fromMillisecondsSinceEpoch(roundTime * 1000),
      status: WalletTxStatus.confirmed,
      direction: from == currentAddress
          ? WalletTxDirection.sent
          : WalletTxDirection.received,
      memo: _decodeNote(tx['note'] as String?),
      explorerUrl: '$explorerBase$hash',
    );
  }

  String? _decodeNote(String? base64Note) {
    if (base64Note == null || base64Note.isEmpty) return null;
    try {
      final decoded = utf8.decode(base64Decode(base64Note));
      final trimmed = decoded.trim();
      return trimmed.isEmpty ? null : trimmed;
    } catch (_) {
      return null;
    }
  }
}
