import 'dart:convert';

import '../utils/json_model_callback.dart';
import 'base_handler.dart';
import 'ethereum_handler.dart';
import 'solana_handler.dart';

/// Registers the `CryptoHandler` JS bridge and dispatches to
/// [EthereumHandler] or [SolanaHandler] depending on `jsData.network`.
class CryptoHandler extends BaseWebViewHandler {
  final EthereumHandler _eth;
  final SolanaHandler _sol;

  CryptoHandler({
    required super.context,
    required EthereumHandler ethHandler,
    required SolanaHandler solHandler,
  })  : _eth = ethHandler,
        _sol = solHandler;

  @override
  void registerHandlers() {
    controller!.addJavaScriptHandler(
      handlerName: 'CryptoHandler',
      callback: _onMessage,
    );
  }

  Future<void> _onMessage(List<dynamic> callback) async {
    final jsData = JsCallbackModel.fromJson(json.decode(callback[0] as String));

    // Keep child handlers' contexts in sync
    _eth.context = context;
    _eth.controller = controller;
    _sol.context = context;
    _sol.controller = controller;

    if (jsData.network == 'solana') {
      await _sol.handle(jsData);
    } else if (jsData.network == 'ethereum') {
      await _eth.handle(jsData);
    }
  }
}
