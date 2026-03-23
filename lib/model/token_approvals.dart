import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/utils/app_config.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class TokenApproval {
  final String tokenAddress;
  final String tokenSymbol;
  final String tokenName;
  final String spenderAddress;
  final String spenderName;
  final BigInt allowance;
  final DateTime? lastUpdated;
  final int contractDecimals;

  const TokenApproval({
    required this.tokenAddress,
    required this.tokenSymbol,
    required this.tokenName,
    required this.spenderAddress,
    required this.spenderName,
    required this.allowance,
    this.lastUpdated,
    this.contractDecimals = 18,
  });

  static final _maxUint256 = BigInt.parse(
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
    radix: 16,
  );

  bool get isUnlimited => allowance >= _maxUint256;
  bool get isRevoked => allowance == BigInt.zero;
  bool get isDangerous => isUnlimited;

  String get allowanceDisplay {
    if (isUnlimited) return 'Unlimited';
    if (isRevoked) return 'Revoked';
    final display = allowance /
        BigInt.from(10).pow(contractDecimals); // ✅ use actual decimals
    return display.toStringAsFixed(2);
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'tokenAddress': tokenAddress,
        'tokenSymbol': tokenSymbol,
        'tokenName': tokenName,
        'spenderAddress': spenderAddress,
        'spenderName': spenderName,
        'allowance': allowance.toString(),
        'lastUpdated': lastUpdated?.toIso8601String(),
        'contractDecimals': contractDecimals,
      };

  factory TokenApproval.fromJson(Map<String, dynamic> j) => TokenApproval(
        tokenAddress: j['tokenAddress'] as String,
        tokenSymbol: j['tokenSymbol'] as String,
        tokenName: j['tokenName'] as String,
        spenderAddress: j['spenderAddress'] as String,
        spenderName: j['spenderName'] as String,
        allowance: BigInt.parse(j['allowance'] as String),
        lastUpdated: j['lastUpdated'] != null
            ? DateTime.tryParse(j['lastUpdated'] as String)
            : null,
        contractDecimals: j['contractDecimals'] as int? ?? 18,
      );

  @override
  String toString() =>
      'TokenApproval($tokenSymbol → $spenderName | $allowanceDisplay)';
}

// ── EVM fetcher (Covalent) ────────────────────────────────────────────────────

class EVMApprovalFetcher {
  final int chainId;
  final String covalentApiKey;

  const EVMApprovalFetcher({
    required this.chainId,
    required this.covalentApiKey,
  });

  static const _knownSpenders = <String, String>{
    '0x000000000022d473030f116ddee9f6b43ac78ba3': 'Uniswap Permit2',
    '0xe592427a0aece92de3edee1f18e0157c05861564': 'Uniswap V3 Router',
    '0x68b3465833fb72a70ecdf485e0e4c7bd8665fc45': 'Uniswap V3 Router 2',
    '0x7a250d5630b4cf539739df2c5dacb4c659f2488d': 'Uniswap V2 Router',
    '0x1111111254eeb25477b68fb85ed929f73a960582': '1inch V5',
    '0x1111111254fb6c44bac0bed2854e76f90643097d': '1inch V4',
    '0x1e0049783f008a0085193e00003d00cd54003c71': 'OpenSea Conduit',
    '0x00000000006c3852cbef3e08e8df289169ede581': 'OpenSea Seaport',
    '0xae7ab96520de3a18e5e111b5eaab095312d7fe84': 'Lido stETH',
    '0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9': 'Aave V2',
    '0x87870bca3f3fd6335c3f4ce8392d69350b4fa4e2': 'Aave V3',
    '0x3d9819210a31b4961b30ef54be2aed79b9c9cd3b': 'Compound',
    '0x99a58482bd75cbab83b27ec03ca68ff489b5788f': 'Curve Router',
  };

  String _resolveSpenderName(String address) {
    return _knownSpenders[address.toLowerCase()] ??
        '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  Future<List<TokenApproval>>? fetchApprovals(String walletAddress) async {
    try {
      final url = Uri.parse(
        'https://api.covalenthq.com/v1/$chainId/approvals/$walletAddress/',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $covalentApiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        debugPrint(
            'TokenApprovalFetcher: HTTP ${response.statusCode} — ${response.body}');
        return [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) return [];

      final items = data['items'] as List<dynamic>? ?? [];
      final approvals = <TokenApproval>[];

      for (final item in items) {
        final tokenAddress =
            (item['token_address'] as String? ?? '').toLowerCase();
        final tokenSymbol = item['ticker_symbol'] as String? ?? '?';
        final tokenName = item['contract_name'] as String? ?? tokenSymbol;
        final spenders = item['spenders'] as List<dynamic>? ?? [];

        for (final spender in spenders) {
          final spenderAddress =
              (spender['spender_address'] as String? ?? '').toLowerCase();
          final allowanceRaw = spender['allowance'] as String? ?? '0';
          final blockSignedAt = spender['block_signed_at'] as String?;

          BigInt allowance;
          try {
            allowance = BigInt.parse(allowanceRaw);
          } catch (_) {
            allowance = BigInt.zero;
          }

          print('allowance: $allowance');

          if (allowance == BigInt.zero) continue;

          approvals.add(TokenApproval(
            tokenAddress: tokenAddress,
            tokenSymbol: tokenSymbol,
            tokenName: tokenName,
            spenderAddress: spenderAddress,
            spenderName: _resolveSpenderName(spenderAddress),
            allowance: allowance,
            contractDecimals: item['contract_decimals'] as int? ?? 18,
            lastUpdated:
                blockSignedAt != null ? DateTime.tryParse(blockSignedAt) : null,
          ));
        }
      }

      approvals.sort((a, b) {
        if (a.isDangerous && !b.isDangerous) return -1;
        if (!a.isDangerous && b.isDangerous) return 1;
        return 0;
      });

      return approvals;
    } catch (e) {
      debugPrint('TokenApprovalFetcher error: $e');
      return [];
    }
  }
}

// ── Factory ───────────────────────────────────────────────────────────────────

extension TokenApprovalFetcherFactory on EVMApprovalFetcher {
  static EVMApprovalFetcher forChain({required int chainId}) {
    return EVMApprovalFetcher(
      chainId: chainId,
      covalentApiKey: covalApiKey,
    );
  }
}
