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
      return 'x402: ${coin.getSymbol()} does not support x402 payments. '
          'Switch to an EVM chain (Base, Ethereum) to use x402.';
    }

    final headers = _buildRequestHeaders(paymentHeader, probeResult.version);

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return 'x402 payment accepted.\n\nResponse: ${response.body}';
    }

    // v1+ may include a receipt header
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

  /// Build request headers per version spec.
  Map<String, String> _buildRequestHeaders(
      String paymentHeader, X402Version version) {
    return switch (version) {
      // v0: original header name from early drafts
      X402Version.v0 => {
          'X-Payment': paymentHeader,
          'Content-Type': 'application/json',
        },
      // v1: canonical header name
      X402Version.v1 => {
          'X-PAYMENT': paymentHeader,
          'Content-Type': 'application/json',
        },
      // v2: adds version hint header so servers can fast-path
      X402Version.v2 => {
          'X-PAYMENT': paymentHeader,
          'X-Payment-Version': '2',
          'Content-Type': 'application/json',
        },
    };
  }

  /// Pick the best payment option, with per-version network/scheme rules.
  X402PaymentOption? _pickOption(
      List<X402PaymentOption> options, X402Version version) {
    final supportedNetworks = switch (version) {
      X402Version.v0 => ['base-mainnet', 'base-sepolia'],
      X402Version.v1 => ['base-mainnet', 'base-sepolia'],
      // v2 adds Optimism and Arbitrum
      X402Version.v2 => [
          'base-mainnet',
          'base-sepolia',
          'optimism-mainnet',
          'optimism-sepolia',
          'arbitrum-mainnet',
          'arbitrum-sepolia',
        ],
    };

    const supportedSchemes = ['exact'];

    // Prefer mainnet over testnet
    X402PaymentOption? testnetFallback;

    for (final option in options) {
      if (!supportedSchemes.contains(option.scheme)) continue;
      if (!supportedNetworks.contains(option.network)) continue;

      if (!option.network.contains('sepolia')) return option;
      testnetFallback ??= option;
    }

    return testnetFallback;
  }

  /// Decimal places per asset, with per-version overrides.
  int _decimalsForAsset(String asset, X402Version version) {
    // Normalise to lowercase contract address or symbol
    final key = asset.toLowerCase();
    return switch (key) {
      // USDC on all supported networks
      String k when k.contains('usdc') => 6,
      // v2 introduced native ETH micro-payments (18 decimals)
      String k when k.contains('eth') && version == X402Version.v2 => 18,
      // USDT
      String k when k.contains('usdt') => 6,
      // default: USDC standard
      _ => 6,
    };
  }

  /// Human-readable ticker per asset.
  String _symbolForAsset(String asset, X402Version version) {
    final key = asset.toLowerCase();
    if (key.contains('usdt')) return 'USDT';
    if (key.contains('eth')) return 'ETH';
    return 'USDC';
  }
}

// ── x402 response models ──────────────────────────────────────────────────────

class X402Response {
  final int x402Version;
  final List<X402PaymentOption> accepts;
  final String? error;

  X402Response({
    required this.x402Version,
    required this.accepts,
    this.error,
  });

  factory X402Response.fromJson(Map<String, dynamic> json) {
    // Accept both 'x402Version' (v1+) and legacy 'version' key (v0 drafts)
    final rawVersion = json['x402Version'] ?? json['version'] ?? 1;

    return X402Response(
      x402Version: rawVersion as int,
      accepts: (json['accepts'] as List)
          .map((e) => X402PaymentOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
    );
  }
}

class X402PaymentOption {
  final String scheme;
  final String network;
  final String maxAmountRequired;
  final String resource;
  final String? description;
  final String? mimeType;
  final String payTo;
  final int maxTimeoutSeconds;
  final String asset;
  final Map<String, dynamic>? extra;

  X402PaymentOption({
    required this.scheme,
    required this.network,
    required this.maxAmountRequired,
    required this.resource,
    this.description,
    this.mimeType,
    required this.payTo,
    required this.maxTimeoutSeconds,
    required this.asset,
    this.extra,
  });

  factory X402PaymentOption.fromJson(Map<String, dynamic> json) {
    return X402PaymentOption(
      scheme: json['scheme'] as String,
      network: json['network'] as String,
      maxAmountRequired: json['maxAmountRequired'] as String,
      resource: json['resource'] as String,
      description: json['description'] as String?,
      mimeType: json['mimeType'] as String?,
      payTo: json['payTo'] as String,
      maxTimeoutSeconds: json['maxTimeoutSeconds'] as int? ?? 300,
      asset: json['asset'] as String,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }
}
