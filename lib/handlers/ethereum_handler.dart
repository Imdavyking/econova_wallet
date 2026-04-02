import 'dart:convert';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

import '../coins/ethereum_coin.dart';
import '../main.dart';
import '../utils/json_model_callback.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import 'base_handler.dart';

/// Handles all `ethereum` and EVM-related JS bridge calls coming from
/// `CryptoHandler` (ethereum branch) inside the WebView.
class EthereumHandler extends BaseWebViewHandler {
  /// Callback so the parent can rebuild / switch chain state.
  final Future<String> Function(int chainId, String rpc) onSwitchChain;

  EthereumHandler({
    required super.context,
    required this.onSwitchChain,
  });

  @override
  void registerHandlers() {
    // EthereumHandler does NOT register its own named JS handler.
    // It is invoked by EthereumHandlerDispatch (CryptoHandler) when
    // jsData.network == 'ethereum'. The dispatch lives in CryptoHandler.
  }

  // ── Public entry point ────────────────────────────────────────────────────

  /// Called by [CryptoHandler] when `jsData.network == 'ethereum'`.
  Future<void> handle(JsCallbackModel jsData) async {
    final chainId = pref.get(dappChainIdKey) as int;
    final coin = evmFromChainId(chainId)!;
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final web3Response = await coin.importData(data);

    final privateKey = web3Response.privateKey!;
    final credentials = web3dart.EthPrivateKey.fromHex(privateKey);
    final sendingAddress = web3Response.address;

    switch (jsData.name) {
      case 'requestAccounts':
        await _requestAccounts(jsData, sendingAddress);
        break;
      case 'signPersonalMessage':
        await _signPersonalMessage(jsData, credentials);
        break;
      case 'signMessage':
        await _signMessage(jsData, credentials, privateKey);
        break;
      case 'signTypedMessage':
        await _signTypedMessage(jsData, privateKey, chainId);
        break;
      case 'signTransaction':
        await _signTransaction(
            jsData, coin, credentials, sendingAddress, chainId);
        break;
      case 'ecRecover':
        await _ecRecover(jsData);
        break;
      case 'watchAsset':
        await _watchAsset(jsData, coin);
        break;
      case 'addEthereumChain':
        await _addEthereumChain(jsData, chainId, sendingAddress, coin);
        break;
      case 'switchEthereumChain':
        await _switchEthereumChain(jsData, chainId, sendingAddress);
        break;
      default:
        sendError(jsData.network.toString(), 'Operation not supported',
            jsData.id ?? 0);
    }
  }

  // ── Private handlers ──────────────────────────────────────────────────────

  Future<void> _requestAccounts(
      JsCallbackModel jsData, String sendingAddress) async {
    final existing = await getWeb3Address('ethereum', sendingAddress);
    if (existing != null) {
      await _setEthereumAddress(jsData.id, sendingAddress);
      return;
    }
    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: jsData.url,
      onConfirm: () async {
        try {
          await _setEthereumAddress(jsData.id, sendingAddress);
          await saveWeb3Address('ethereum', sendingAddress);
        } catch (e) {
          sendError(
              'ethereum', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        sendError('ethereum', 'user rejected connection', jsData.id ?? 0);
        _pop();
      },
    );
  }

  Future<void> _signPersonalMessage(
      JsCallbackModel jsData, web3dart.EthPrivateKey credentials) async {
    final data = JsDataModel.fromJson(jsData.object ?? {});
    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: personalSignKey,
      data: data.data,
      networkIcon: null,
      name: null,
      onConfirm: () async {
        try {
          final signed = credentials
              .signPersonalMessageToUint8List(txDataToUintList(data.data));
          sendResponse(
              'ethereum', bytesToHex(signed, include0x: true), jsData.id ?? 0);
        } catch (e) {
          sendError(
              'ethereum', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
      onReject: () {
        sendError('ethereum', 'user rejected signature', jsData.id ?? 0);
        _pop();
      },
    );
  }

  Future<void> _signMessage(JsCallbackModel jsData,
      web3dart.EthPrivateKey credentials, String privateKey) async {
    final data = JsDataModel.fromJson(jsData.object ?? {});
    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: normalSignKey,
      data: data.data,
      networkIcon: null,
      name: null,
      onConfirm: () async {
        try {
          String hex;
          try {
            hex = EthSigUtil.signMessage(
                privateKey: privateKey, message: txDataToUintList(data.data));
          } catch (_) {
            hex = bytesToHex(
                credentials.signPersonalMessageToUint8List(
                    txDataToUintList(data.data)),
                include0x: true);
          }
          sendResponse('ethereum', hex, jsData.id ?? 0);
        } catch (e) {
          sendError(
              'ethereum', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
      onReject: () {
        sendError('ethereum', 'user rejected signature', jsData.id ?? 0);
        _pop();
      },
    );
  }

  Future<void> _signTypedMessage(
      JsCallbackModel jsData, String privateKey, int chainId) async {
    final data = JsEthSignTypedData.fromJson(jsData.object ?? {});
    if (data.domain.chainId != chainId) {
      sendError(
          'ethereum',
          'Provided chainId ${data.domain.chainId} must match the active chainId $chainId',
          jsData.id ?? 0);
      return;
    }
    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: typedMessageSignKey,
      data: data.raw,
      networkIcon: null,
      name: null,
      onConfirm: () async {
        try {
          final hex = EthSigUtil.signTypedData(
              privateKey: privateKey,
              jsonData: data.raw,
              version: TypedDataVersion.V4);
          sendResponse('ethereum', hex, jsData.id ?? 0);
        } catch (e) {
          sendError(
              'ethereum', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
      onReject: () {
        sendError('ethereum', 'user rejected signature', jsData.id ?? 0);
        _pop();
      },
    );
  }

  Future<void> _signTransaction(
      JsCallbackModel jsData,
      EthereumCoin coin,
      web3dart.EthPrivateKey credentials,
      String sendingAddress,
      int chainId) async {
    final data = JsTransactionObject.fromJson(jsData.object ?? {});
    if (!context.mounted) return;
    await signTransactionUI(
      gasPriceInWei_: null,
      to: data.to,
      from: sendingAddress,
      txData: data.data,
      valueInWei_: data.value,
      gasInWei_: null,
      networkIcon: null,
      context: context,
      symbol: coin.symbol,
      name: '',
      chainId: chainId,
      title: 'Sign Transaction',
      onConfirm: () async {
        try {
          final client = web3dart.Web3Client(coin.rpc, Client());
          final signed = await client.signTransaction(
            credentials,
            web3dart.Transaction(
              to: data.to != null
                  ? web3dart.EthereumAddress.fromHex(data.to!)
                  : null,
              value: data.value != null
                  ? web3dart.EtherAmount.inWei(BigInt.parse(data.value!))
                  : null,
              nonce: data.nonce != null ? int.parse(data.nonce!) : null,
              data: data.data == null ? null : txDataToUintList(data.data!),
              gasPrice: data.gasPrice != null
                  ? web3dart.EtherAmount.inWei(BigInt.parse(data.gasPrice!))
                  : null,
            ),
            chainId: chainId,
          );
          final txHash = await client.sendRawTransaction(signed);
          sendResponse('ethereum', txHash, jsData.id ?? 0);
        } catch (e) {
          if (kDebugMode) print(e);
          sendError(
              'ethereum', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        sendError('ethereum', 'user rejected transaction', jsData.id ?? 0);
        _pop();
      },
    );
  }

  Future<void> _ecRecover(JsCallbackModel jsData) async {
    final data = JsEcRecoverObject.fromJson(jsData.object ?? {});
    try {
      final sig = EthSigUtil.recoverPersonalSignature(
          message: txDataToUintList(data.message), signature: data.signature);
      sendResponse('ethereum', sig, jsData.id ?? 0);
    } catch (e) {
      sendError('ethereum', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
    }
  }

  Future<void> _watchAsset(JsCallbackModel jsData, EthereumCoin coin) async {
    final data = JsWatchAsset.fromJson(jsData.object ?? {});
    try {
      if (data.decimals == null) throw Exception('invalid asset decimals');
      if (data.symbol == null) throw Exception('invalid asset symbol');
      coin.validateAddress(data.contract);
      throw Exception('not Implemented');
    } catch (e) {
      sendError('ethereum', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
    }
  }

  Future<void> _addEthereumChain(JsCallbackModel jsData, int chainId,
      String sendingAddress, EthereumCoin currentCoin) async {
    final data = JsAddEthereumChain.fromJson(jsData.object ?? {});
    try {
      final switchChainId = BigInt.parse(data.chainId).toInt();
      final currentChain = evmFromChainId(chainId)!;
      EthereumCoin? switchChain = evmFromChainId(switchChainId);

      if (chainId == switchChainId) {
        sendNull('ethereum', jsData.id ?? 0);
        return;
      }

      if (switchChain == null) {
        // Build a new chain from the request params
        final blockExplorers = data.blockExplorerUrls;
        final rpcUrls = data.rpcUrls;

        if (data.symbol == null || data.symbol!.isEmpty) {
          sendError('ethereum', 'no symbol set', jsData.id ?? 0);
          return;
        }
        if (data.name!.isEmpty) {
          sendError('ethereum', 'no name set', jsData.id ?? 0);
          return;
        }
        if (rpcUrls.isEmpty) {
          sendError('ethereum', 'no rpc url set', jsData.id ?? 0);
          return;
        }
        if (blockExplorers.isEmpty) {
          sendError('ethereum', 'no explorer url set', jsData.id ?? 0);
          return;
        }

        String blockExplorer = blockExplorers[0];
        if (blockExplorer.endsWith('/')) {
          blockExplorer = blockExplorer.substring(0, blockExplorer.length - 1);
        }

        switchChain = EthereumCoin(
          rpc: rpcUrls[0],
          chainId: switchChainId,
          blockExplorer: '$blockExplorer/tx/$blockExplorerPlaceholder',
          symbol: data.symbol!,
          default_: data.symbol!,
          image: 'assets/ethereum-2.png',
          coinType: 60,
          name: data.chainName,
          geckoID: '',
          rampID: '',
          payScheme: '',
        );

        Map<String, dynamic> addBlockChain = {};
        if (pref.get(newEVMChainKey) != null) {
          addBlockChain =
              Map.from(jsonDecode(pref.get(newEVMChainKey) as String));
        }
        addBlockChain[data.chainName] = switchChain.toJson();

        if (!context.mounted) return;
        await addEthereumChain(
          context: context,
          jsonObj: json.encode(Map.from({'name': data.chainName})
            ..addAll(switchChain.toJson())
            ..remove('image')
            ..remove('coinType')),
          onConfirm: () async {
            try {
              const id = 83;
              final res = await post(
                Uri.parse(switchChain!.rpc),
                body: json.encode({
                  'jsonrpc': '2.0',
                  'method': 'eth_chainId',
                  'params': [],
                  'id': id
                }),
                headers: {'Content-Type': 'application/json'},
              );
              if (res.statusCode ~/ 100 >= 4) throw Exception(res.body);
              final decoded = json.decode(res.body);
              final returnedId =
                  BigInt.parse(decoded['result'] as String).toInt();
              if (decoded['id'] != id) throw Exception('invalid id returned');
              if (returnedId != switchChainId) {
                throw Exception('chain Id mismatch with eth_chainId');
              }
              await pref.put(newEVMChainKey, jsonEncode(addBlockChain));
              supportedChains.add(switchChain);
              _pop();
            } catch (e) {
              sendError('ethereum', e.toString().replaceAll('"', "'"),
                  jsData.id ?? 0);
              _pop();
            }
          },
          onReject: () async {
            sendError('ethereum', 'canceled', jsData.id ?? 0);
            _pop();
          },
        );
      } else {
        final initString = _addChainScript(switchChain, sendingAddress);
        await _doSwitchChain(
            currentChain, switchChain, initString, jsData, chainId);
      }
    } catch (e) {
      sendError('ethereum', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
    }
  }

  Future<void> _switchEthereumChain(
      JsCallbackModel jsData, int chainId, String sendingAddress) async {
    try {
      final data = JsSwitchEthereumChain.fromJson(jsData.object ?? {});
      final switchChainId = BigInt.parse(data.chainId).toInt();
      final currentChain = evmFromChainId(chainId)!;
      final switchChain = evmFromChainId(switchChainId);

      if (chainId == switchChainId) {
        sendNull('ethereum', jsData.id ?? 0);
        return;
      }
      if (switchChain == null) {
        sendError('ethereum', 'unknown chain id', jsData.id ?? 0);
        return;
      }
      final initString = _addChainScript(switchChain, sendingAddress);
      await _doSwitchChain(
          currentChain, switchChain, initString, jsData, chainId);
    } catch (e) {
      sendError('ethereum', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _setEthereumAddress(dynamic id, String address) async {
    await sendCustom('window.ethereum.setAddress("$address");');
    await sendCustom('window.ethereum.sendResponse($id, ["$address"])');
  }

  String _addChainScript(EthereumCoin chain, String address) => '''
window.ethereum.setConfig({
  ethereum:{
    chainId: ${chain.chainId},
    rpcUrl: "${chain.rpc}",
    address: "$address"
  }
})''';

  Future<void> _doSwitchChain(
    EthereumCoin current,
    EthereumCoin target,
    String initScript,
    JsCallbackModel jsData,
    int oldChainId,
  ) async {
    await switchEthereumChain(
      context: context,
      currentChain: current,
      switchChain: target,
      onConfirm: () async {
        final newInit = await onSwitchChain(target.chainId, target.rpc);
        await sendCustom(newInit);
        final chain16 = '0x${target.chainId.toRadixString(16)}';
        await sendCustom('trustwallet.ethereum.emitChainChanged("$chain16");');
        await sendNull('ethereum', jsData.id ?? 0);
        _pop();
      },
      onReject: () async {
        sendError('ethereum', 'canceled', jsData.id ?? 0);
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
