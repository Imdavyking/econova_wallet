import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Base class for all WebView JavaScript bridge handlers.
/// Each handler registers one or more [InAppWebViewController] JS handlers
/// and encapsulates the complete logic for a single blockchain / domain.
abstract class BaseWebViewHandler {
  /// The [BuildContext] used to show modals. May be updated by the parent widget.
  BuildContext context;

  /// Lazily-set controller reference. Set by [attach] before any callbacks fire.
  InAppWebViewController? controller;

  BaseWebViewHandler({required this.context});

  /// Register all JS handlers on [ctrl] and store a reference.
  void attach(InAppWebViewController ctrl) {
    controller = ctrl;
    registerHandlers();
  }

  /// Subclasses implement this to call [controller!.addJavaScriptHandler(…)].
  void registerHandlers();

  // ── Shared JS response helpers ─────────────────────────────────────────────

  Future<void> sendResponse(String network, String message, int methodId) {
    final script = "window.$network.sendResponse($methodId, \"$message\")";
    return _eval(script);
  }

  Future<void> sendError(String network, String message, int methodId) {
    final script = "window.$network.sendError($methodId, \"$message\")";
    return _eval(script);
  }

  Future<void> sendNull(String network, int methodId) {
    final script = "window.$network.sendResponse($methodId, null)";
    return _eval(script);
  }

  Future<void> sendCustom(String source) => _eval(source);

  Future<void> _eval(String source) {
    return controller!
        .evaluateJavascript(source: source)
        .then((v) => debugPrint(v?.toString()))
        .onError((e, _) => debugPrint(e.toString()));
  }

  // ── localStorage helpers (keyed per network + address) ────────────────────

  String _localKey(String network, String address) =>
      'walletName-$network-$address';

  Future<void> saveWeb3Address(String network, String address) =>
      _eval("localStorage.setItem('${_localKey(network, address)}','wallet')");

  Future<dynamic> getWeb3Address(String network, String address) =>
      controller!.evaluateJavascript(
          source: "localStorage.getItem('${_localKey(network, address)}')");

  Future<void> removeWeb3Address(String network, String address) => _eval(
      "localStorage.removeItem('${_localKey(network, address)}')");
}
