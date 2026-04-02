import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:wallet_app/extensions/first_or_null.dart';
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

// ── V1 legacy network name → CAIP-2 mapping ───────────────────────────────────
// Used only for backward-compatible V1 option picking.

const _v1ToCapip2 = <String, String>{
  'base': 'eip155:8453',
  'base-mainnet': 'eip155:8453',
  'base-sepolia': 'eip155:84532',
  'optimism-mainnet': 'eip155:10',
  'optimism-sepolia': 'eip155:11155111',
  'arbitrum-mainnet': 'eip155:42161',
  'arbitrum-sepolia': 'eip155:421614',
  'polygon': 'eip155:137',
  'polygon-mainnet': 'eip155:137',
  'polygon-amoy': 'eip155:80002',
  'avalanche': 'eip155:43114',
  'avalanche-fuji': 'eip155:43113',
  'ethereum': 'eip155:1',
  'ethereum-sepolia': 'eip155:11155111',
  'solana': 'solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp',
  'solana-devnet': 'solana:EtWTRABZaYq6iMfeYKouRu166VU2xqa1',
};

/// Normalises a network string to CAIP-2 format.
/// V2 strings are already CAIP-2; V1 legacy strings are mapped via [_v1ToCapip2].
String _normaliseToCaip2(String network) => _v1ToCapip2[network] ?? network;

// ── Request context — carries original method/body/headers through the flow ───

class X402RequestContext {
  final String url;
  final String method;
  final String? body;
  final Map<String, String> headers;

  const X402RequestContext({
    required this.url,
    this.method = 'GET',
    this.body,
    this.headers = const {},
  });
}

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
  // Probes using the *actual* method + body so a POST-only 402 is caught.

  Future<X402ProbeResult?> probe(
    String url, {
    String method = 'GET',
    String? body,
    Map<String, String> headers = const {},
  }) async {
    final response = await _dispatch(X402RequestContext(
      url: url,
      method: method,
      body: body,
      headers: headers,
    ));

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
        'Supported: ${_supportedVersions.map((v) => v.value).join(', ')}',
      );
    }

    final option = _pickOption(x402.accepts, version);
    if (option == null) {
      throw Exception(
        'No supported payment option for x402 v${version.value}. '
        'Got: ${x402.accepts.map((a) => '${a.scheme}@${a.network}').join(', ')}',
      );
    }

    final signingCoin = _resolveSigningCoin(option) ?? coin;
    final decimals = signingCoin.decimals();
    final rawAmount = BigInt.parse(option.maxAmountRequired);
    final humanAmount =
        (rawAmount / BigInt.from(pow(10, decimals))).toStringAsFixed(decimals);

    return X402ProbeResult(
      option: option,
      humanReadableAmount: '$humanAmount ${signingCoin.getSymbol()}',
      version: version,
    );
  }

  // ── Step 2: Pay and fetch ─────────────────────────────────────────────────
  // Re-dispatches the *original* request with the payment header injected.

  Future<String> payAndFetch(
    String url,
    X402ProbeResult probeResult, {
    String method = 'GET',
    String? body,
    Map<String, String> headers = const {},
  }) async {
    final signingCoin = _resolveSigningCoin(probeResult.option) ?? coin;
    final normalisedNetwork = _normaliseToCaip2(probeResult.option.network);

    if (!_canSignForNetwork(signingCoin, normalisedNetwork)) {
      final requiredSymbol = _symbolForAsset(probeResult.option.asset);
      return 'x402: This resource requires payment on '
          '$normalisedNetwork. '
          'Please switch to a $requiredSymbol wallet and try again.';
    }

    final paymentHeader = await signingCoin.signX402Payment(
      probeResult.option,
      version: probeResult.version.value,
    );

    if (paymentHeader == null) {
      return 'x402: ${signingCoin.getSymbol()} does not support x402 payments '
          'on network $normalisedNetwork.';
    }

    // Merge payment header into original headers — preserves Content-Type etc.
    final paymentHeaders = {
      ...headers,
      ..._buildPaymentHeaders(paymentHeader, probeResult.version),
    };

    final response = await _dispatch(X402RequestContext(
      url: url,
      method: method,
      body: body,
      headers: paymentHeaders,
    ));

    if (response.statusCode == 200) {
      return 'x402 payment accepted.\n\nResponse: ${response.body}';
    }

    final receipt = response.headers['payment-response'];
    final receiptNote = receipt != null ? '\nReceipt: $receipt' : '';
    return 'x402: Server returned ${response.statusCode}: '
        '${response.body}$receiptNote';
  }

  // ── Full flow without confirmation ────────────────────────────────────────

  Future<String> fetchWithPayment(
    String url, {
    String method = 'GET',
    String? body,
    Map<String, String> headers = const {},
  }) async {
    final probeResult = await probe(
      url,
      method: method,
      body: body,
      headers: headers,
    );
    if (probeResult == null) {
      final response = await _dispatch(X402RequestContext(
        url: url,
        method: method,
        body: body,
        headers: headers,
      ));
      return response.body;
    }

    return payAndFetch(
      url,
      probeResult,
      method: method,
      body: body,
      headers: headers,
    );
  }

  // ── HTTP dispatch — single place for all method routing ──────────────────

  Future<http.Response> _dispatch(X402RequestContext ctx) {
    final uri = Uri.parse(ctx.url);
    final headers = {
      if (ctx.body != null) 'Content-Type': 'application/json',
      ...ctx.headers,
    };

    return switch (ctx.method.toUpperCase()) {
      'GET' => http.get(uri, headers: headers),
      'POST' => http.post(uri, headers: headers, body: ctx.body),
      'PUT' => http.put(uri, headers: headers, body: ctx.body),
      'PATCH' => http.patch(uri, headers: headers, body: ctx.body),
      'DELETE' => http.delete(uri, headers: headers, body: ctx.body),
      _ => throw Exception('Unsupported HTTP method: ${ctx.method}'),
    };
  }

  // ── Signing coin resolution ───────────────────────────────────────────────

  Coin? _resolveSigningCoin(X402PaymentOption option) {
    if (_coinMatchesAsset(coin, option.asset)) return coin;
    return coin.findToken(option.asset);
  }

  // ── CAIP-2-based network check ────────────────────────────────────────────
  //
  // Both V2 (native CAIP-2) and normalised V1 strings are compared against
  // the coin's caip2ChainId. Falls back to namespace prefix matching so that
  // e.g. a wildcard facilitator registration ("eip155:*") still works.

  bool _canSignForNetwork(Coin c, String normalisedNetwork) {
    // Exact CAIP-2 match — the happy path
    if (c.caip2ChainId == normalisedNetwork) return true;

    // Check network tokens (e.g. USDCX lives on the Stacks coin)
    if (c.networkTokens.any((t) => t.caip2ChainId == normalisedNetwork)) {
      return true;
    }

    // Same namespace fallback — e.g. coin is "eip155:1", network is "eip155:8453"
    // Allow if the coin's namespace matches and the coin can sign EVM payments.
    final coinNamespace = c.caip2ChainId.split(':').first;
    final networkNamespace = normalisedNetwork.split(':').first;
    return coinNamespace == networkNamespace && c.supportsX402;
  }

  bool _coinMatchesAsset(Coin c, String asset) {
    final key = asset.toLowerCase();
    final sym = c.getSymbol().toLowerCase();
    final contract = c.tokenAddress()?.toLowerCase();
    final keyTail = key.split('.').last;

    return sym == key ||
        sym == keyTail ||
        (contract != null &&
            (contract == key || contract.split('.').last == keyTail));
  }

  // ── Option picking — V2 uses pure CAIP-2; V1 uses legacy name mapping ─────

  X402PaymentOption? _pickOption(
      List<X402PaymentOption> options, X402Version version) {
    final myCaip2 = coin.caip2ChainId; // e.g. "stacks:1", "eip155:1"
    final myNamespace = myCaip2.split(':').first;

    bool isTestnet(String network) =>
        network.contains('sepolia') ||
        network.contains('2147483648') ||
        network.contains('testnet') ||
        network.contains('devnet') ||
        network.contains('fuji') ||
        network.contains('amoy');

    X402PaymentOption? pickFromCaip2List(Iterable<String> caip2Networks) {
      X402PaymentOption? testnetFallback;
      for (final option in options) {
        if (option.scheme != 'exact') continue;
        final normNet = _normaliseToCaip2(option.network);
        if (!caip2Networks.contains(normNet)) continue;
        if (!isTestnet(normNet)) return option; // prefer mainnet
        testnetFallback ??= option;
      }
      return testnetFallback;
    }

    // ── Exact coin match ─────────────────────────────────────────────────────
    final exactMatch = options.firstWhereOrNull(
      (o) => o.scheme == 'exact' && _normaliseToCaip2(o.network) == myCaip2,
    );
    if (exactMatch != null) return exactMatch;

    // ── Same-namespace match (e.g. any eip155 chain for an EVM coin) ─────────
    final sameNamespace = options
        .where((o) =>
            o.scheme == 'exact' &&
            _normaliseToCaip2(o.network).startsWith('$myNamespace:'))
        .toList();

    if (sameNamespace.isNotEmpty) {
      X402PaymentOption? testnetFallback;
      for (final option in sameNamespace) {
        final normNet = _normaliseToCaip2(option.network);
        if (!isTestnet(normNet)) return option;
        testnetFallback ??= option;
      }
      if (testnetFallback != null) return testnetFallback;
    }

    // ── V1-only cross-namespace fallback (EVM coin → Stacks option or vice versa)
    if (version == X402Version.v0 || version == X402Version.v1) {
      const stacksNetworks = {'stacks:1', 'stacks:2147483648'};
      final isStacksCoin = myNamespace == 'stacks';
      final fallbackNetworks = isStacksCoin ? <String>{} : stacksNetworks;
      return pickFromCaip2List(fallbackNetworks);
    }

    return null;
  }

  // ── Version-aware payment header key ─────────────────────────────────────

  Map<String, String> _buildPaymentHeaders(
      String paymentHeader, X402Version version) {
    return switch (version) {
      X402Version.v0 => {'X-Payment': paymentHeader},
      X402Version.v1 => {'X-PAYMENT': paymentHeader},
      X402Version.v2 => {'payment-signature': paymentHeader},
    };
  }

  String _symbolForAsset(String asset) {
    if (_coinMatchesAsset(coin, asset)) return coin.getSymbol();
    final token = coin.findToken(asset);
    if (token != null) return token.getSymbol();
    final tail = asset.split('.').last;
    return tail.length > 10 ? '${tail.substring(0, 6)}…' : tail.toUpperCase();
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
  Map<String, dynamic> toJson() => {'url': url};
}

class X402PaymentOption {
  final String scheme;
  final String network;
  final String maxAmountRequired;
  final X402Resource? resource;
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
    this.resource,
    this.description,
    this.mimeType,
    required this.payTo,
    required this.maxTimeoutSeconds,
    required this.asset,
    this.extra,
  });

  /// The network normalised to CAIP-2 format (V1 names are mapped).
  String get normalisedNetwork => _normaliseToCaip2(network);

  Map<String, dynamic> toJson() => {
        'scheme': scheme,
        'network': network,
        'amount': maxAmountRequired,
        'asset': asset,
        'payTo': payTo,
        'maxTimeoutSeconds': maxTimeoutSeconds,
        if (description != null) 'description': description,
        if (mimeType != null) 'mimeType': mimeType,
        if (extra != null) 'extra': extra,
      };

  factory X402PaymentOption.fromJson(
    Map<String, dynamic> json, {
    X402Resource? topLevelResource,
  }) {
    final rawAmount = json['maxAmountRequired'] ?? json['amount'];
    if (rawAmount == null) {
      throw const FormatException(
          'x402 option missing both maxAmountRequired and amount fields');
    }

    X402Resource? resource = topLevelResource;
    final rawResource = json['resource'];
    if (rawResource is String) {
      resource = X402Resource(url: rawResource);
    } else if (rawResource is Map<String, dynamic>) {
      resource = X402Resource.fromJson(rawResource);
    }

    final payTo = json['payTo'] as String?;
    if (payTo == null || payTo.isEmpty) {
      throw const FormatException('x402 option missing required payTo field');
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
      asset: json['asset'] as String? ??
          (throw const FormatException(
              'x402 option missing required asset field')),
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }
}
