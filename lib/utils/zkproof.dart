import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ZkProofBridge {
  ZkProofBridge._internal();
  static final ZkProofBridge instance = ZkProofBridge._internal();

  InAppWebViewController? _controller;
  bool _ready = false;
  final _pending = <String, Completer<ZkProofResult>>{};

  /// True once the WASM prover has finished initializing.
  bool get isReady => _ready;

  /// Listenable counterpart of [isReady], for disabling/enabling
  /// send buttons while proving isn't available yet.
  final readyNotifier = ValueNotifier<bool>(false);

  // Call this once in main — add the widget to your tree but keep it hidden
  Widget buildHiddenWebView() {
    return SizedBox(
      width: 1,
      height: 1,
      child: InAppWebView(
        initialFile: "assets/zkworker/index.html",
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          // Required for SharedArrayBuffer (Barretenberg threads)
          allowUniversalAccessFromFileURLs: true,
          allowFileAccessFromFileURLs: true,
          // Android needs these for COOP/COEP
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        ),
        onConsoleMessage: (controller, msg) {
          debugPrint('ZkWorker console: ${msg.message}');
        },
        onWebViewCreated: (controller) {
          _controller = controller;

          controller.addJavaScriptHandler(
            handlerName: 'ZkBridgeReady',
            callback: (args) {
              final msg = args.isNotEmpty ? args[0].toString() : '';
              if (msg.startsWith('error:')) {
                debugPrint('ZkBridge init failed: $msg');
              } else {
                _ready = true;
                readyNotifier.value = true;
                debugPrint('ZkBridge ready ✅');
              }
            },
          );

          controller.addJavaScriptHandler(
            handlerName: 'ZkBridge',
            callback: (args) {
              if (args.isEmpty) return;
              final data =
                  jsonDecode(args[0].toString()) as Map<String, dynamic>;
              final id = data['id'] as String;
              final completer = _pending.remove(id);
              if (completer == null) return;
              if (data['success'] == true) {
                completer.complete(ZkProofResult(
                  proofBytesHex: data['proofBytesHex'],
                  publicInputsHex: data['publicInputsHex'],
                ));
              } else {
                completer.completeError(Exception(data['error']));
              }
            },
          );
        },
// Remove onLoadStop entirely — not needed anymore  ),
      ),
    );
  }

  Future<ZkProofResult> generateProof(Map<String, dynamic> input) async {
    if (!_ready || _controller == null) {
      throw Exception('ZkBridge not ready yet');
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final completer = Completer<ZkProofResult>();
    _pending[id] = completer;

    await _controller!.evaluateJavascript(source: '''
      (async () => {
        try {
          const result = await window.__zkGenerateProof(${jsonEncode(input)});
          window.ZkBridge.postMessage(JSON.stringify({
            id: "$id", success: true,
            proofBytesHex: result.proofBytesHex,
            publicInputsHex: result.publicInputsHex
          }));
        } catch(e) {
          window.ZkBridge.postMessage(JSON.stringify({
            id: "$id", success: false, error: e.toString()
          }));
        }
      })();
    ''');

    try {
      return await completer.future.timeout(const Duration(minutes: 3));
    } finally {
      // Ensure no dangling completer remains if the timeout fires
      // before a late JS response arrives.
      _pending.remove(id);
    }
  }

  /// Tears down proving state, e.g. on logout. The hidden WebView widget
  /// itself will be re-created with a fresh controller the next time
  /// Wallet() (or wherever buildHiddenWebView() is mounted) builds.
  void reset() {
    _controller = null;
    _ready = false;
    readyNotifier.value = false;
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('ZkBridge reset before completion'));
      }
    }
    _pending.clear();
  }
}

class ZkProofResult {
  final String proofBytesHex;
  final String publicInputsHex;
  const ZkProofResult(
      {required this.proofBytesHex, required this.publicInputsHex});
}
