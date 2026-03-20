import 'dart:convert';

import 'package:bs58check/bs58check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:sui/utils/sha.dart';
import 'package:wallet_app/main.dart';

import '../coins/near_coin.dart';
import '../utils/json_model_callback.dart';
import '../model/near_message_borsh.dart';
import '../model/near_trx_obj.dart';
import '../service/wallet_service.dart';
import '../utils/rpc_urls.dart';
import 'base_handler.dart';

/// Handles `NightyHandler` JS bridge messages (NEAR protocol).
class NearHandler extends BaseWebViewHandler {
  NearHandler({required super.context});

  @override
  void registerHandlers() {
    controller!.addJavaScriptHandler(
      handlerName: 'NightyHandler',
      callback: _onMessage,
    );
  }

  Future<void> _onMessage(List<dynamic> callback) async {
    final jsData = JsCallbackModel.fromJson(
        json.decode(callback[0] as String) as Map<String, dynamic>);
    final coin = getNearBlockChains().first;
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final accountDetail = await coin.importData(data);
    final sendingAddress = accountDetail.address;

    switch (jsData.name) {
      case 'disconnect':
        await removeWeb3Address('near', sendingAddress);
        break;
      case 'signTransaction':
        await _signTransaction(jsData, coin, sendingAddress);
        break;
      case 'signMessage':
        await _signMessage(jsData, coin, sendingAddress);
        break;
      case 'connect':
        await _connect(jsData, coin, sendingAddress);
        break;
    }
  }

  Future<void> _signTransaction(
      JsCallbackModel jsData, NearCoin coin, String sendingAddress) async {
    final trxObj = NearDappTrx.fromJson(jsData.object!);
    if (!context.mounted) return;
    await signNearTransaction(
      from: sendingAddress,
      txData: trxObj,
      networkIcon: null,
      context: context,
      coin: coin,
      symbol: coin.symbol,
      name: '',
      onConfirm: () async {
        try {
          final nearTrx = await coin.signDappTrx(trxObj);
          await _sendResult(
              json.encode({'signature': nearTrx.signature}), jsData.id!);
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected msg', jsData.id ?? 0);
        _pop();
      },
    );
  }

  Future<void> _signMessage(
      JsCallbackModel jsData, NearCoin coin, String sendingAddress) async {
    final data = JsNearMessageObject.fromJson(jsData.object ?? {});
    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: '',
      data: data.message,
      networkIcon: null,
      name: null,
      onReject: () async {
        await _sendError('user rejected msg', jsData.id ?? 0);
        _pop();
      },
      onConfirm: () async {
        try {
          final params = NearMessageBorsh(
            message: data.message,
            recipient: data.recipient,
            nonce: data.nonce.data,
            callbackUrl: data.callbackUrl,
          );
          final msg = await coin.signMessage(sha256(params.serialize()));
          final signedMsg = json.encode({
            'accountId': sendingAddress,
            'publicKey': base58.encode(HEX.decode(sendingAddress) as Uint8List),
            'signature': base64.encode(msg),
            'state': data.state,
          });
          await _sendResult(signedMsg, jsData.id!);
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
    );
  }

  Future<void> _connect(
      JsCallbackModel jsData, NearCoin coin, String sendingAddress) async {
    final addressData = json.encode({
      'accountId': sendingAddress,
      'publicKey': base58.encode(HEX.decode(sendingAddress) as Uint8List),
    });

    final existing = await getWeb3Address('near', sendingAddress);
    if (existing != null) {
      await _sendResult(addressData, jsData.id!);
      return;
    }
    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: jsData.url,
      onConfirm: () async {
        try {
          await _sendResult(addressData, jsData.id!);
          await saveWeb3Address('near', sendingAddress);
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected connection', jsData.id ?? 0);
        _pop();
      },
    );
  }

  // ── NEAR-specific JS helpers ───────────────────────────────────────────────

  Future<void> _sendResult(String message, int methodId) {
    final script = "window.nightly.near.sendResponse($methodId, '$message')";
    return sendCustom(script);
  }

  Future<void> _sendError(String message, int methodId) {
    final script = "window.nightly.near.sendError($methodId, \"$message\")";
    return sendCustom(script);
  }

  void _pop() {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
