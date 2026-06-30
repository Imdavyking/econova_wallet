// ── Local server ────────────────────────────────────────────────────────────
// Serves assets/zkworker/* over http://127.0.0.1:<port> with COOP/COEP
// headers set, since file:// has no headers and may block SharedArrayBuffer
// (which bb.js's UltraHonkBackend likely needs for threaded WASM proving).
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ZkLocalServer {
  ZkLocalServer._();
  static final ZkLocalServer instance = ZkLocalServer._();

  HttpServer? _server;
  int? _port;

  bool get isRunning => _server != null;

  Future<int> start() async {
    if (_server != null) return _port!;

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _port = _server!.port;
    debugPrint('ZkLocalServer: listening on http://127.0.0.1:$_port');

    _server!.listen((HttpRequest request) async {
      try {
        var path = request.uri.path;
        if (path == '/' || path.isEmpty) path = '/index.html';

        final assetPath = 'assets/zkworker$path';
        final data = await rootBundle.load(assetPath);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        request.response
          ..headers.set('Cross-Origin-Opener-Policy', 'same-origin')
          ..headers.set('Cross-Origin-Embedder-Policy', 'require-corp')
          ..headers.set('Content-Type', _contentTypeFor(path))
          ..statusCode = HttpStatus.ok
          ..add(bytes);
      } catch (e) {
        debugPrint('ZkLocalServer: 404 for ${request.uri.path} — $e');
        request.response.statusCode = HttpStatus.notFound;
      } finally {
        await request.response.close();
      }
    });

    return _port!;
  }

  String _contentTypeFor(String path) {
    if (path.endsWith('.html')) return 'text/html';
    if (path.endsWith('.js')) return 'application/javascript';
    if (path.endsWith('.wasm')) return 'application/wasm';
    if (path.endsWith('.json')) return 'application/json';
    return 'application/octet-stream';
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _port = null;
  }
}
