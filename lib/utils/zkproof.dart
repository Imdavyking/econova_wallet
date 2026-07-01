import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wallet_app/utils/zklocalserver.dart';

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

class ZkProofResult {
  final String proofBytesHex;
  final String publicInputsHex;
  const ZkProofResult(
      {required this.proofBytesHex, required this.publicInputsHex});
}

class ZkProofBridge {
  ZkProofBridge._internal();
  static final ZkProofBridge instance = ZkProofBridge._internal();

  HeadlessInAppWebView? _headless;
  InAppWebViewController? _controller;
  bool _ready = false;
  Completer<void>? _readyCompleter;

  final _pending = <String, Completer<ZkProofResult>>{};

  String? _acvmB64;
  String? _noircB64;

  bool get isReady => _ready;
  final readyNotifier = ValueNotifier<bool>(false);

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

  /// Boots (or reuses) a single persistent headless webview, served
  /// via the local COOP/COEP server so SharedArrayBuffer works for
  /// proof generation, and also used for note generation.
  /// Call this once, e.g. in Wallet.initState(), and await it lazily
  /// on first use if you'd rather not block startup.
  Future<void> ensureStarted() async {
    if (_headless != null) {
      await _readyCompleter?.future.timeout(const Duration(seconds: 15));
      return;
    }

    await preloadWasm();
    final port = await ZkLocalServer.instance.start();

    _readyCompleter = Completer<void>();

    _headless = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri('http://127.0.0.1:$port/')),
      initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
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
              if (!_readyCompleter!.isCompleted) {
                _readyCompleter!.completeError(Exception(msg));
              }
            } else {
              _ready = true;
              readyNotifier.value = true;
              if (!_readyCompleter!.isCompleted) _readyCompleter!.complete();
              debugPrint('ZkBridge ready ✅');
            }
          },
        );

        controller.addJavaScriptHandler(
          handlerName: 'ZkBridge',
          callback: (args) {
            if (args.isEmpty) return;
            final data = jsonDecode(args[0].toString()) as Map<String, dynamic>;
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
        await _injectWasmAssets(controller);
      },
    );

    await _headless!.run();
    await _readyCompleter!.future.timeout(const Duration(seconds: 15));
  }

  Future<void> _injectWasmAssets(InAppWebViewController controller) async {
    try {
      const chunkSize = 512 * 1024;
      await _injectB64InChunks(
          controller, '__acvmWasmB64', _acvmB64!, chunkSize);
      await _injectB64InChunks(
          controller, '__noircWasmB64', _noircB64!, chunkSize);
      debugPrint('ZkBridge: WASM bytes injected ✅');
    } catch (e) {
      debugPrint('ZkBridge: failed to inject WASM assets: $e');
    }
  }

  Future<void> _injectB64InChunks(
    InAppWebViewController controller,
    String varName,
    String b64,
    int chunkSize,
  ) async {
    await controller.evaluateJavascript(source: 'window.$varName = "";');
    var offset = 0;
    while (offset < b64.length) {
      final chunk =
          b64.substring(offset, (offset + chunkSize).clamp(0, b64.length));
      final escaped = chunk.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
      await controller.evaluateJavascript(
          source: 'window.$varName += "$escaped";');
      offset += chunkSize;
    }
  }

  Future<ZkNote> generateNote() async {
    await ensureStarted();

    final completer = Completer<ZkNote>();
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
          window.flutter_inappwebview.callHandler('$handlerName', JSON.stringify(result));
        } catch(e) {
          window.flutter_inappwebview.callHandler('$handlerName', JSON.stringify({ error: e.toString() }));
        }
      })();
    ''');

    return completer.future.timeout(const Duration(seconds: 10));
  }

  Future<ZkProofResult> generateProof(Map<String, dynamic> input) async {
    await ensureStarted();

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final completer = Completer<ZkProofResult>();
    _pending[id] = completer;

    await _controller!.evaluateJavascript(source: '''
      if (window.flutter_inappwebview) {
        window.__zkGenerateProof(${jsonEncode(input)})
          .then((result) => {
            window.flutter_inappwebview.callHandler('ZkBridge', JSON.stringify({
              id: "$id", success: true,
              proofBytesHex: result.proofBytesHex,
              publicInputsHex: result.publicInputsHex
            }));
          })
          .catch((e) => {
            window.flutter_inappwebview.callHandler('ZkBridge', JSON.stringify({
              id: "$id", success: false, error: e.toString()
            }));
          });
      }
    ''');

    try {
      return await completer.future.timeout(const Duration(minutes: 3));
    } finally {
      _pending.remove(id);
    }
  }

  /// Full teardown — dispose the headless webview and stop the local
  /// server. Call this when the user logs out / leaves the wallet.
  Future<void> reset() async {
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('ZkBridge reset before completion'));
      }
    }
    _pending.clear();

    await _headless?.dispose();
    _headless = null;
    _controller = null;
    _ready = false;
    readyNotifier.value = false;
    _readyCompleter = null;

    await ZkLocalServer.instance.stop();
  }
}
