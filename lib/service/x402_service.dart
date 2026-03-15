import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:wallet_app/interface/coin.dart';

/// Result from probing a URL that returned 402.
class X402ProbeResult {
  final X402PaymentOption option;
  final String humanReadableAmount;

  X402ProbeResult({
    required this.option,
    required this.humanReadableAmount,
  });
}

class X402Service {
  final Coin coin;

  X402Service({required this.coin});

  // ── Step 1: Probe — returns null if not a 402 ────────────────────────────────

  Future<X402ProbeResult?> probe(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 402) return null;

    final X402Response x402;
    try {
      x402 = X402Response.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('Failed to parse 402 response: $e');
    }

    final option = _pickOption(x402.accepts);
    if (option == null) {
      throw Exception(
        'No supported payment option. '
        'Supported: exact on base-mainnet/base-sepolia. '
        'Got: ${x402.accepts.map((a) => '${a.scheme}@${a.network}').join(', ')}',
      );
    }

    final decimals = _decimalsForAsset(option.asset);
    final rawAmount = BigInt.parse(option.maxAmountRequired);
    final humanAmount =
        (rawAmount / BigInt.from(pow(10, decimals))).toStringAsFixed(decimals);

    return X402ProbeResult(
      option: option,
      humanReadableAmount: '$humanAmount USDC',
    );
  }

  // ── Step 2: Pay and fetch — coin handles signing ──────────────────────────────

  Future<String> payAndFetch(String url, X402ProbeResult probeResult) async {
    // Delegate signing entirely to the coin
    final paymentHeader = await coin.signX402Payment(probeResult.option);

    if (paymentHeader == null) {
      return 'x402: ${coin.getSymbol()} does not support x402 payments. '
          'Switch to an EVM chain (Base, Ethereum) to use x402.';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-PAYMENT': paymentHeader,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return 'x402 payment accepted.\n\nResponse: ${response.body}';
    }

    return 'x402: Server returned ${response.statusCode}: ${response.body}';
  }

  // ── Full flow without confirmation ────────────────────────────────────────────

  Future<String> fetchWithPayment(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 402) return response.body;

    final probeResult = await probe(url);
    if (probeResult == null) return response.body;

    return payAndFetch(url, probeResult);
  }

  // ── Pick best supported option ────────────────────────────────────────────────

  X402PaymentOption? _pickOption(List<X402PaymentOption> options) {
    const supportedNetworks = ['base-mainnet', 'base-sepolia'];
    const supportedSchemes = ['exact'];

    for (final option in options) {
      if (supportedSchemes.contains(option.scheme) &&
          supportedNetworks.contains(option.network)) {
        return option;
      }
    }
    return null;
  }

  // ── Token decimals ────────────────────────────────────────────────────────────

  int _decimalsForAsset(String asset) {
    // All x402 tokens currently use 6 decimals (USDC standard)
    return 6;
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
    return X402Response(
      x402Version: json['x402Version'] as int? ?? 1,
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