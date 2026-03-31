import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:multiversx_sdk/multiversx.dart' as multiversx;
import 'package:wallet_app/main.dart';
import 'package:wallet_app/model/multix_sign_model.dart';
import 'package:web3dart/crypto.dart';

import '../coins/multiversx_coin.dart';
import '../service/wallet_service.dart';
import '../utils/rpc_urls.dart';
import 'base_handler.dart';

/// Handles `Multiversx` JS bridge messages from the WebView.
class MultiversxHandler extends BaseWebViewHandler {
  MultiversxHandler({required super.context});

  @override
  void registerHandlers() {
    controller!.addJavaScriptHandler(
      handlerName: 'Multiversx',
      callback: _onMessage,
    );
  }

  Future<void> _onMessage(List<dynamic> callback) async {
    final response = json.decode(callback[0] as String) as Map;
    final coin = getEGLDBlockchains().first;
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final multiversxRes = await coin.importData(data);

    final signer =
        multiversx.UserSecretKey(HEX.decode(multiversxRes.privateKey!));
    final keys = multiversx.Wallet(signer);

    switch (response['type']) {
      case 'logout':
        await _postMessage(
            {'target': 'erdw-contentScript', 'type': '', 'data': true});
        break;
      case 'signMessage':
        await _signMessage(response, coin, keys);
        break;
      case 'signTransactions':
        await _signTransactions(response, coin, keys, multiversxRes);
        break;
      case 'connect':
        await _connect(response, coin, keys, multiversxRes);
        break;
    }
  }

  Future<void> _signMessage(
      Map response, dynamic coin, multiversx.Wallet keys) async {
    final message = response['data']['message'] as String;
    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: '',
      data: message,
      networkIcon: null,
      name: null,
      onReject: () async => _pop(),
      onConfirm: () async {
        try {
          final serialized = MultiversxCoin.serializeForSigning(message);
          final userSigner = keys.signer as multiversx.UserSigner;
          final signature = await compute(
            MultiversxCoin.signMessage,
            MultiversDappMessage(
              signer: userSigner.secretKey,
              message: serialized,
            ),
          );
          await _postMessage({
            'target': 'erdw-contentScript',
            'type': '',
            'data': {'message': message, 'signature': bytesToHex(signature)},
          });
        } catch (_) {
        } finally {
          _pop();
        }
      },
    );
  }

  Future<void> _signTransactions(Map response, dynamic coin,
      multiversx.Wallet keys, dynamic multiversxRes) async {
    final jsData = MultiversXSignTransModel.fromJson(
        response['data'] as Map<String, dynamic>);
    final allTrans = jsData.transactions!;

    for (int i = 0; i < allTrans.length; i++) {
      final e = allTrans[i];
      List<int> txData = [];
      try {
        txData = base64.decode(e.data!);
      } catch (_) {
        txData = txDataToUintList(e.data!);
      }
      if (!context.mounted) return;
      await signMultiversXTransaction(
        gasPrice: '${e.gasPrice}',
        to: e.receiver,
        from: jsData.from,
        txData: e.data ?? '',
        value_: e.value,
        networkIcon: null,
        context: context,
        gasLimit: '${e.gasLimit}',
        symbol: 'EGLD',
        chainId: e.chainId,
        name: '',
        onConfirm: () async {
          try {
            await keys.synchronize(coin.getProxy());
            final networkConfig =
                await coin.getProxy().getNetworkConfiguration();
            final trans = multiversx.Transaction(
              nonce: multiversx.Nonce(e.nonce ?? keys.account.nonce.value),
              chainId: multiversx.ChainId(e.chainId),
              sender: multiversx.Address.fromBech32(jsData.from),
              receiver: multiversx.Address.fromBech32(e.receiver),
              gasPrice: multiversx.GasPrice(
                  e.gasPrice ?? networkConfig.minGasPrice.value),
              gasLimit: multiversx.GasLimit(
                  e.gasLimit ?? networkConfig.minGasLimit.value),
              transactionVersion: multiversx.TransactionVersion(
                  e.version ?? networkConfig.minTransactionVersion.value),
              balance: multiversx.Balance(BigInt.parse(e.value ?? '0')),
              data: multiversx.TransactionPayload(txData),
            );
            final signTrans = await compute(
              MultiversxCoin.signTransaction,
              MultiversDappTransaction(
                signer: keys.signer,
                transaction: trans,
              ),
            );
            allTrans[i].signature = (signTrans).signature.hex;
            await _postMessage({
              'target': 'erdw-contentScript',
              'type': '',
              'data': allTrans.toList(),
            });
          } catch (e, sk) {
            if (kDebugMode) {
              print(e);
              print(sk);
            }
          } finally {
            _pop();
          }
        },
        onReject: () async {
          await _postMessage({
            'target': 'erdw-contentScript',
            'type': '',
            'data': {'name': 'CanceledError'},
          });
          _pop();
        },
      );
    }
  }

  Future<void> _connect(Map response, dynamic coin, multiversx.Wallet keys,
      dynamic multiversxRes) async {
    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: response['url'] as String?,
      authToken: response['data'] as String?,
      onConfirm: () async {
        try {
          final authToken = (response['data'] as String?) ?? '';
          List<int> signature = [];
          final hasToken = authToken.trim().isNotEmpty;
          if (hasToken) {
            final msg = '${multiversxRes.address}$authToken{}';
            final serialized = MultiversxCoin.serializeForSigning(msg);
            final userSigner = keys.signer as multiversx.UserSigner;
            signature = await compute(
              MultiversxCoin.signMessage,
              MultiversDappMessage(
                signer: userSigner.secretKey,
                message: serialized,
              ),
            );
          }
          final data = <String, dynamic>{
            'address': multiversxRes.address,
            'name': 'Main',
          };
          if (hasToken) data['signature'] = bytesToHex(signature);
          await _postMessage({
            'target': 'erdw-contentScript',
            'type': 'connectResponse',
            'data': data,
          });
        } catch (_) {
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _postMessage({
          'target': 'erdw-contentScript',
          'type': 'connectResponse',
          'data': {'name': 'CanceledError'},
        });
        _pop();
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _postMessage(Map<String, dynamic> data) =>
      sendCustom('window.postMessage(${json.encode(data)}, window.origin)');

  void _pop() {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
