import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:starknet/starknet.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/json_model_callback.dart';

import '../coins/starknet_coin.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import '../utils/starknet_call.dart';
import 'base_handler.dart';

/// Handles `StarknetHandler` JS bridge messages.
class StarknetHandler extends BaseWebViewHandler {
  StarknetHandler({required super.context});

  @override
  void registerHandlers() {
    controller!.addJavaScriptHandler(
      handlerName: 'StarknetHandler',
      callback: _onMessage,
    );
  }

  Future<void> _onMessage(List<dynamic> args) async {
    final coin = starkNetCoins.first;
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final coinData = await coin.importData(data);
    final payload = jsonDecode(args.first as String) as Map<String, dynamic>;
    final type = payload['type'] as String?;
    final requestId = payload['requestId'] as String;
    final origin = payload['url'] as String;
    final chainId = await coin.getChainId();

    switch (type) {
      case 'request':
        final request = payload['args'] as Map<String, dynamic>;
        final requestType = request['type'] as String;
        await _handleRequest(
          requestType: requestType,
          origin: origin,
          requestId: requestId,
          chainId: chainId.toHexString(),
          coinData: coinData,
          request: request,
          coin: coin,
        );
        break;
      case 'on':
      case 'off':
        // Subscription management – no-op for now
        break;
    }
  }

  Future<void> _handleRequest({
    required String requestType,
    required String origin,
    required String requestId,
    required String chainId,
    required AccountData coinData,
    required Map<String, dynamic> request,
    required dynamic coin,
  }) async {
    Future<void> respond(Map<String, dynamic> data) async {
      final js =
          'window.starknet.sendResponse("$requestId", ${json.encode(data)})';
      await sendCustom(js);
    }

    Future<void> respondError(String message) =>
        respond({'error': message});

    const unsupported = [
      'wallet_addStarknetChain',
      'wallet_switchStarknetChain',
      'wallet_watchAsset',
    ];

    try {
      switch (requestType) {
        case 'wallet_requestAccounts':
        case 'wallet_requestChainId':
          await _requestAccountsOrChainId(
              requestType, origin, requestId, chainId, coinData, respond);
          break;

        case 'wallet_deploymentData':
          final deployData = await coin.getDeploymentData();
          await respond({
            'origin': origin,
            'requestId': requestId,
            'chainId': chainId,
            'requestType': requestType,
            'address': coinData.address,
            'class_hash': deployData.classHash,
            'salt': deployData.addressSalt,
            'calldata': deployData.constructorCalldata,
            'version': deployData.version,
          });
          break;

        case 'wallet_addDeclareTransaction':
          await _addDeclareTransaction(
              request, origin, requestId, chainId, coinData, coin, respond,
              respondError);
          break;

        case 'wallet_addInvokeTransaction':
          await _addInvokeTransaction(
              request, origin, requestId, chainId, coinData, coin, respond,
              respondError);
          break;

        case 'wallet_getPermissions':
          await respond({
            'origin': origin,
            'requestId': requestId,
            'chainId': chainId,
            'address': coinData.address,
            'requestType': requestType,
            'permissions': ['accounts'],
          });
          break;

        case 'wallet_supportedSpecs':
          await respond({
            'origin': origin,
            'requestId': requestId,
            'chainId': chainId,
            'address': coinData.address,
            'requestType': requestType,
            'specs': ['0.6', '0.7'],
          });
          break;

        case 'wallet_signTypedData':
          await _signTypedData(
              request, origin, requestId, chainId, coinData, respond,
              respondError);
          break;

        default:
          if (unsupported.contains(requestType)) {
            await respondError('Unsupported request type: $requestType');
          } else {
            await respondError('Unknown request type: $requestType');
          }
      }
    } catch (e) {
      await respondError(e.toString().replaceAll('"', "'"));
    }
  }

  Future<void> _requestAccountsOrChainId(
    String requestType,
    String origin,
    String requestId,
    String chainId,
    AccountData coinData,
    Future<void> Function(Map<String, dynamic>) respond,
  ) async {
    final responseData = {
      'origin': origin,
      'requestId': requestId,
      'chainId': chainId,
      'address': coinData.address,
      'requestType': requestType,
    };

    if (requestType == 'wallet_requestAccounts') {
      final existing = await getWeb3Address('starknet', coinData.address);
      if (existing != null) {
        await respond(responseData);
        return;
      }
      if (!context.mounted) return;
      await connectWalletModal(
        context: context,
        url: origin,
        onConfirm: () async {
          try {
            await sendCustom(
                'window.starknet.sendResponse("$requestId", ${json.encode(responseData)})');
            await saveWeb3Address('starknet', coinData.address);
          } catch (e) {
            await sendCustom(
                'window.starknet.sendResponse("$requestId", ${json.encode({'error': e.toString().replaceAll('"', "'")})})');
          } finally {
            _pop();
          }
        },
        onReject: () async {
          await sendCustom(
              'window.starknet.sendResponse("$requestId", ${json.encode({'error': 'user rejected connection'})})');
          _pop();
        },
      );
      return;
    }
    await respond(responseData);
  }

  Future<void> _addDeclareTransaction(
    Map<String, dynamic> request,
    String origin,
    String requestId,
    String chainId,
    AccountData coinData,
    dynamic coin,
    Future<void> Function(Map<String, dynamic>) respond,
    Future<void> Function(String) respondError,
  ) async {
    final params = request['params'] as Map<String, dynamic>;
    final declareResult = await coin.addDeclareDapp(
        AddDeclareTransactionParameters.fromJson(params));
    if (declareResult == null) {
      await respondError('Failed to declare contract');
      return;
    }
    await respond({
      'origin': origin,
      'requestId': requestId,
      'chainId': chainId,
      'address': coinData.address,
      'requestType': 'wallet_addDeclareTransaction',
      'txHash': declareResult.transactionHash.toHexString(),
      'classHash': declareResult.classHash.toHexString(),
    });
  }

  Future<void> _addInvokeTransaction(
    Map<String, dynamic> request,
    String origin,
    String requestId,
    String chainId,
    AccountData coinData,
    dynamic coin,
    Future<void> Function(Map<String, dynamic>) respond,
    Future<void> Function(String) respondError,
  ) async {
    final params = request['params'] as Map<String, dynamic>;
    final calls = (params['calls'] as List?) ?? [];
    final dapCalls =
        calls.map((c) => StarknetCall.fromJson(c as Map<String, dynamic>)).toList();

    if (!context.mounted) return;
    await signStarkNetTransaction(
      from: coinData.address,
      networkIcon: null,
      context: context,
      symbol: coin.symbol,
      dapCalls: dapCalls,
      name: '',
      onConfirm: () async {
        try {
          final txHash = await coin.executeInvokeDapp(dapCalls);
          await respond({
            'origin': origin,
            'requestId': requestId,
            'chainId': chainId,
            'address': coinData.address,
            'requestType': 'wallet_addInvokeTransaction',
            'txHash': txHash,
          });
        } catch (e) {
          await respondError(e.toString().replaceAll('"', "'"));
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await respondError('user rejected transaction');
        _pop();
      },
      title: 'Sign Transaction',
    );
  }

  Future<void> _signTypedData(
    Map<String, dynamic> request,
    String origin,
    String requestId,
    String chainId,
    AccountData coinData,
    Future<void> Function(Map<String, dynamic>) respond,
    Future<void> Function(String) respondError,
  ) async {
    final params = request['params'] as Map<String, dynamic>?;
    final data = SignTypedDomain.fromJson(params ?? {});

    if (data.chainId != BigInt.parse(chainId).toInt()) {
      await respondError(
          '${data.chainId} can not be signed on $chainId');
      return;
    }

    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: typedMessageSignKey,
      data: json.encode(params),
      networkIcon: null,
      name: null,
      onConfirm: () async {
        try {
          final typedData = TypedData.fromJson(params!);
          final hash =
              typedData.hash(Felt.fromHexString(coinData.address));
          final signature = starknetSign(
            privateKey: BigInt.parse(coinData.privateKey!),
            messageHash: hash,
          );
          await respond({
            'origin': origin,
            'requestId': requestId,
            'chainId': chainId,
            'address': coinData.address,
            'requestType': 'wallet_signTypedData',
            'signature': [
              signature.r.toString(),
              signature.s.toString(),
            ],
          });
        } catch (e) {
          await respondError(e.toString().replaceAll('"', "'"));
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await respondError('user rejected signature');
        _pop();
      },
    );
  }

  void _pop() {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
