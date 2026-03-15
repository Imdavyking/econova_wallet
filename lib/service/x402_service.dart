import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:wallet_app/interface/coin.dart';

// ── Supported versions ────────────────────────────────────────────────────────

enum X402Version {
  v0(0),
  v1(1),
  v2(2);

  final int value;
  const X402Version(this.value);

  static X402Version? fromInt(int v) {
    for (final ver in X402Version.values) {
      if (ver.value == v) return ver;
    }
    return null;
  }
}

const _supportedVersions = {X402Version.v0, X402Version.v1, X402Version.v2};

// ── Probe result ──────────────────────────────────────────────────────────────

class X402ProbeResult {
  final X402PaymentOption option;
  final String humanReadableAmount;
  final X402Version version;

  X402ProbeResult({
    required this.option,
    required this.humanReadableAmount,
    required this.version,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class X402Service {
  final Coin coin;

  X402Service({required this.coin});

  // ── Step 1: Probe ─────────────────────────────────────────────────────────

  Future<X402ProbeResult?> probe(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 402) return null;

    final X402Response x402;
    try {
      x402 = X402Response.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('Failed to parse 402 response: $e');
    }

    final version = X402Version.fromInt(x402.x402Version);
    if (version == null || !_supportedVersions.contains(version)) {
      throw Exception(
        'Unsupported x402 version: ${x402.x402Version}. '
        'Supported versions: ${_supportedVersions.map((v) => v.value).join(', ')}',
      );
    }

    final option = _pickOption(x402.accepts, version);
    if (option == null) {
      throw Exception(
        'No supported payment option for x402 v${version.value}. '
        'Got: ${x402.accepts.map((a) => '${a.scheme}@${a.network}').join(', ')}',
      );
    }

    final decimals = _decimalsForAsset(option.asset, version);
    final rawAmount = BigInt.parse(option.maxAmountRequired);
    final humanAmount =
        (rawAmount / BigInt.from(pow(10, decimals))).toStringAsFixed(decimals);
    final symbol = _symbolForAsset(option.asset, version);

    return X402ProbeResult(
      option: option,
      humanReadableAmount: '$humanAmount $symbol',
      version: version,
    );
  }

  // ── Step 2: Pay and fetch ─────────────────────────────────────────────────

  Future<String> payAndFetch(String url, X402ProbeResult probeResult) async {
    final paymentHeader = await coin.signX402Payment(
      probeResult.option,
      version: probeResult.version.value,
    );

    if (paymentHeader == null) {
      return 'x402: ${coin.getSymbol()} does not support x402 payments '
          'on network ${probeResult.option.network}.';
    }

    final headers = _buildRequestHeaders(paymentHeader, probeResult.version);
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return 'x402 payment accepted.\n\nResponse: ${response.body}';
    }

    final receipt =
        response.headers['x-payment-response'] ?? response.headers['x-receipt'];
    final receiptNote = receipt != null ? '\nReceipt: $receipt' : '';

    return 'x402: Server returned ${response.statusCode}: ${response.body}$receiptNote';
  }

  // ── Full flow without confirmation ────────────────────────────────────────

  Future<String> fetchWithPayment(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 402) return response.body;

    final probeResult = await probe(url);
    if (probeResult == null) return response.body;

    return payAndFetch(url, probeResult);
  }

  // ── Version-aware helpers ─────────────────────────────────────────────────

  Map<String, String> _buildRequestHeaders(
      String paymentHeader, X402Version version) {
    return switch (version) {
      X402Version.v0 => {
          'X-Payment': paymentHeader,
          'Content-Type': 'application/json',
        },
      X402Version.v1 => {
          'X-PAYMENT': paymentHeader,
          'Content-Type': 'application/json',
        },
      X402Version.v2 => {
          'X-PAYMENT': paymentHeader,
          'X-Payment-Version': '2',
          'Content-Type': 'application/json',
        },
    };
  }

  /// Pick the best payment option based on what the current coin supports.
  ///
  /// Stacks coins prefer `stacks:*` networks; EVM coins prefer EVM networks.
  /// Within each group, mainnet is preferred over testnet.
  X402PaymentOption? _pickOption(
      List<X402PaymentOption> options, X402Version version) {
    final evmNetworks = switch (version) {
      X402Version.v0 || X402Version.v1 => [
          'base-mainnet',
          'base-sepolia',
        ],
      X402Version.v2 => [
          'base-mainnet',
          'base-sepolia',
          'optimism-mainnet',
          'optimism-sepolia',
          'arbitrum-mainnet',
          'arbitrum-sepolia',
          'polygon-mainnet',
          'polygon-amoy',
        ],
    };

    const stacksNetworks = [
      'stacks:1', // mainnet
      'stacks:2147483648', // testnet
    ];

    const supportedSchemes = ['exact'];

    final isStacksCoin = coin.getPayScheme() == 'stacks';
    final preferredNetworks = isStacksCoin ? stacksNetworks : evmNetworks;
    final fallbackNetworks = isStacksCoin ? evmNetworks : stacksNetworks;

    X402PaymentOption? firstMatch(List<String> networks) {
      X402PaymentOption? testnetFallback;
      for (final option in options) {
        if (!supportedSchemes.contains(option.scheme)) continue;
        if (!networks.contains(option.network)) continue;
        final isTestnet = option.network.contains('sepolia') ||
            option.network.contains('2147483648');
        if (!isTestnet) return option;
        testnetFallback ??= option;
      }
      return testnetFallback;
    }

    return firstMatch(preferredNetworks) ?? firstMatch(fallbackNetworks);
  }

  int _decimalsForAsset(String asset, X402Version version) {
    final key = asset.toLowerCase();
    return switch (key) {
      'stx' => 6,
      'sbtc' => 8,
      String k when k.contains('usdc') => 6,
      String k when k.contains('usdt') => 6,
      String k when k.contains('eth') && version == X402Version.v2 => 18,
      _ => 6,
    };
  }

  String _symbolForAsset(String asset, X402Version version) {
    final key = asset.toLowerCase();
    if (key == 'stx') return 'STX';
    if (key == 'sbtc') return 'sBTC';
    if (key.contains('usdt')) return 'USDT';
    if (key.contains('eth')) return 'ETH';
    if (key.contains('usdcx')) return 'USDCX';
    return 'USDC';
  }
}

// ── x402 response models ──────────────────────────────────────────────────────

class X402Response {
  final int x402Version;
  final List<X402PaymentOption> accepts;
  final X402Resource? resource;
  final String? error;

  X402Response({
    required this.x402Version,
    required this.accepts,
    this.resource,
    this.error,
  });

  factory X402Response.fromJson(Map<String, dynamic> json) {
    final rawVersion = json['x402Version'] ?? json['version'] ?? 1;

    X402Resource? resource;
    final rawResource = json['resource'];
    if (rawResource is String) {
      resource = X402Resource(url: rawResource);
    } else if (rawResource is Map<String, dynamic>) {
      resource = X402Resource.fromJson(rawResource);
    }

    return X402Response(
      x402Version: rawVersion as int,
      accepts: (json['accepts'] as List)
          .map((e) => X402PaymentOption.fromJson(
                e as Map<String, dynamic>,
                topLevelResource: resource,
              ))
          .toList(),
      resource: resource,
      error: json['error'] as String?,
    );
  }
}

class X402Resource {
  final String url;
  X402Resource({required this.url});
  factory X402Resource.fromJson(Map<String, dynamic> json) =>
      X402Resource(url: json['url'] as String);
}

class X402PaymentOption {
  final String scheme;
  final String network;
  final String maxAmountRequired;
  final X402Resource? resource;
  final String? description;
  final String? mimeType;

  /// Always present — required field in PaymentMiddlewareConfig.
  final String payTo;

  final int maxTimeoutSeconds;

  /// Optional in PaymentMiddlewareConfig — defaults to 'STX' when absent.
  final String asset;

  final Map<String, dynamic>? extra;

  X402PaymentOption({
    required this.scheme,
    required this.network,
    required this.maxAmountRequired,
    this.resource,
    this.description,
    this.mimeType,
    required this.payTo,
    required this.maxTimeoutSeconds,
    required this.asset,
    this.extra,
  });

  factory X402PaymentOption.fromJson(
    Map<String, dynamic> json, {
    X402Resource? topLevelResource,
  }) {
    // Stacks uses 'amount'; EVM uses 'maxAmountRequired'
    final rawAmount = json['maxAmountRequired'] ?? json['amount'];
    if (rawAmount == null) {
      throw FormatException(
          'x402 option missing both maxAmountRequired and amount fields');
    }

    // resource may be inside the option (EVM) or inherited from the
    // top-level response (Stacks)
    X402Resource? resource = topLevelResource;
    final rawResource = json['resource'];
    if (rawResource is String) {
      resource = X402Resource(url: rawResource);
    } else if (rawResource is Map<String, dynamic>) {
      resource = X402Resource.fromJson(rawResource);
    }

    // payTo is required per PaymentMiddlewareConfig — throw early if missing
    // so the error is clear rather than a null deref later during signing.
    final payTo = json['payTo'] as String?;
    if (payTo == null || payTo.isEmpty) {
      throw FormatException('x402 option missing required payTo field');
    }

    return X402PaymentOption(
      scheme: json['scheme'] as String,
      network: json['network'] as String,
      maxAmountRequired: rawAmount.toString(),
      resource: resource,
      description: json['description'] as String?,
      mimeType: json['mimeType'] as String?,
      payTo: payTo,
      maxTimeoutSeconds: json['maxTimeoutSeconds'] as int? ?? 300,
      // asset is optional in PaymentMiddlewareConfig — default to 'STX'
      asset: (json['asset'] as String?) ?? 'STX',
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }
}
