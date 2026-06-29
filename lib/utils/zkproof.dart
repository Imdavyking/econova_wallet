import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ZkNote {
  final String nullifier;
  final String secret;
  final String commitment;
  const ZkNote({
    required this.nullifier,
    required this.secret,
    required this.commitment,
  });
}

class ZkProofBridge {
  ZkProofBridge._internal();
  static final ZkProofBridge instance = ZkProofBridge._internal();

  InAppWebViewController? _controller;
  bool _ready = false;
  final _pending = <String, Completer<ZkProofResult>>{};

  // Cached so we only read from assets once per app lifecycle
  String? _acvmB64;
  String? _noircB64;

  bool get isReady => _ready;

  final readyNotifier = ValueNotifier<bool>(false);

  /// Pre-loads WASM bytes from Flutter assets into base64 strings.
  /// Call this once at startup (e.g. in main() after WidgetsFlutterBinding)
  /// so it's ready before the WebView even opens.
  Future<void> preloadWasm() async {
    if (_acvmB64 != null && _noircB64 != null) return;
    final results = await Future.wait([
      rootBundle.load('assets/zkworker/acvm_js_bg.wasm'),
      rootBundle.load('assets/zkworker/noirc_abi_wasm_bg.wasm'),
    ]);
    _acvmB64 = base64Encode(results[0].buffer.asUint8List());
    _noircB64 = base64Encode(results[1].buffer.asUint8List());
    debugPrint('ZkBridge: WASM assets preloaded ✅');
  }

  Widget buildHiddenWebView() {
    return SizedBox(
      width: 1,
      height: 1,
      child: InAppWebView(
        initialFile: "assets/zkworker/index.html",
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          allowUniversalAccessFromFileURLs: true,
          allowFileAccessFromFileURLs: true,
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
        onLoadStop: (controller, url) async {
          // Inject WASM bytes as JS globals immediately after page load,
          // before zkworker.ts init() polls for them.
          await _injectWasmAssets(controller);
        },
      ),
    );
  }

  Future<void> _injectWasmAssets(InAppWebViewController controller) async {
    try {
      // Preload if not already done (defensive — should be called at startup)
      await preloadWasm();

      // Split into chunks to avoid evaluateJavascript string size limits.
      // Each chunk is 512KB of base64 characters.
      const chunkSize = 512 * 1024;

      await _injectB64InChunks(
          controller, '__acvmWasmB64', _acvmB64!, chunkSize);
      await _injectB64InChunks(
          controller, '__noircWasmB64', _noircB64!, chunkSize);

      debugPrint('ZkBridge: WASM bytes injected into WebView ✅');
    } catch (e) {
      debugPrint('ZkBridge: failed to inject WASM assets: $e');
    }
  }

  /// Injects a large base64 string into a JS global by concatenating
  /// chunks, avoiding single evaluateJavascript call size limits.
  Future<void> _injectB64InChunks(
    InAppWebViewController controller,
    String varName,
    String b64,
    int chunkSize,
  ) async {
    // Initialise to empty string
    await controller.evaluateJavascript(source: 'window.$varName = "";');

    var offset = 0;
    while (offset < b64.length) {
      final chunk = b64.substring(
        offset,
        (offset + chunkSize).clamp(0, b64.length),
      );
      // Escape backslashes and quotes just in case (base64 is safe,
      // but be defensive)
      final escaped = chunk.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
      await controller.evaluateJavascript(
        source: 'window.$varName += "$escaped";',
      );
      offset += chunkSize;
    }
  }

  /// Generates a fresh nullifier + secret + commitment via Poseidon2 in JS.
  /// Dart never touches the crypto — everything stays in the zkworker.
  Future<ZkNote> generateNote() async {
    if (!_ready || _controller == null) {
      throw Exception('ZkBridge not ready yet');
    }

    final completer = Completer<ZkNote>();

    // One-shot handler — we use a unique name to avoid collision
    const handlerName = 'ZkNoteResult';
    _controller!.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) {
        if (args.isEmpty) {
          completer.completeError(Exception('ZkNoteResult: empty response'));
          return;
        }
        final data = jsonDecode(args[0].toString()) as Map<String, dynamic>;
        if (data['error'] != null) {
          completer.completeError(Exception(data['error']));
        } else {
          completer.complete(ZkNote(
            nullifier: data['nullifier'] as String,
            secret: data['secret'] as String,
            commitment: data['commitment'] as String,
          ));
        }
      },
    );

    await _controller!.evaluateJavascript(source: '''
    (() => {
      try {
        const result = window.__zkGenerateNote();
        window.flutter_inappwebview.callHandler('$handlerName',
          JSON.stringify(result));
      } catch(e) {
        window.flutter_inappwebview.callHandler('$handlerName',
          JSON.stringify({ error: e.toString() }));
      }
    })();
  ''');

    return completer.future.timeout(const Duration(seconds: 10));
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
          window.flutter_inappwebview.callHandler('ZkBridge', JSON.stringify({
            id: "$id", success: true,
            proofBytesHex: result.proofBytesHex,
            publicInputsHex: result.publicInputsHex
          }));
        } catch(e) {
          window.flutter_inappwebview.callHandler('ZkBridge', JSON.stringify({
            id: "$id", success: false, error: e.toString()
          }));
        }
      })();
    ''');

    try {
      return await completer.future.timeout(const Duration(minutes: 3));
    } finally {
      _pending.remove(id);
    }
  }

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
