import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:wallet_app/coins/fungible_tokens/stack_ft_coin.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/stack_tx_utils.dart';

import '../coins/stack_coin.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import 'base_handler.dart';

// ─── JS message shape ────────────────────────────────────────────────────────
//
// The injected provider sends:
//   {
//     id:       <int>,          // response correlation id
//     name:     <string>,       // method name
//     network:  "stacks",
//     object:   { … },          // method-specific params
//     url:      <string>,       // origin
//   }
//
// Responses are dispatched via:
//   window.stacks.sendResponse(id, result)
//   window.stacks.sendError(id, message)

/// Handles the `StacksHandler` JavaScript bridge for both native STX
/// transfers and SIP-010 fungible-token transfers.
///
/// Supported methods
/// ─────────────────
///   requestAccounts      → return address + public key
///   disconnect           → clear saved address
///   signMessage          → personal sign (UTF-8 or hex)
///   signTransaction      → build + sign a STX token-transfer tx
///   signSIP010Transfer   → build + sign a SIP-010 contract-call tx
class StacksHandler extends BaseWebViewHandler {
  StacksHandler({required super.context});

  @override
  void registerHandlers() {
    controller!.addJavaScriptHandler(
      handlerName: 'StacksHandler',
      callback: _onMessage,
    );
  }

  // ── Dispatcher ────────────────────────────────────────────────────────────

  Future<void> _onMessage(List<dynamic> callback) async {
    final jsData = _StacksMessage.fromJson(
        json.decode(callback[0] as String) as Map<String, dynamic>);

    final coin = getStacksBlockchains().first;
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final accountDetail = await coin.importData(data);
    final sendingAddress = accountDetail.address;

    if (kDebugMode) {
      print('StacksHandler → ${jsData.name} (id=${jsData.id})');
    }

    switch (jsData.name) {
      case 'requestAccounts':
        await _requestAccounts(jsData, sendingAddress, coin);
        break;
      case 'disconnect':
        await removeWeb3Address('stacks', sendingAddress);
        break;
      case 'signMessage':
        await _signMessage(jsData, coin, accountDetail);
        break;
      case 'signTransaction':
        await _signTransaction(jsData, coin, sendingAddress);
        break;
      case 'signSIP010Transfer':
        await _signSIP010Transfer(jsData, sendingAddress);
        break;
      default:
        await _sendError('Unsupported method: ${jsData.name}', jsData.id);
    }
  }

  // ── requestAccounts ───────────────────────────────────────────────────────

  Future<void> _requestAccounts(
    _StacksMessage jsData,
    String sendingAddress,
    StacksCoin coin,
  ) async {
    final existing = await getWeb3Address('stacks', sendingAddress);
    if (existing != null) {
      await _sendResponse(jsData.id, {
        'address': sendingAddress,
        'publicKey': (await coin
                .importData(WalletService.getActiveKey(walletImportType)!.data))
            .publicKey,
      });
      return;
    }

    if (!context.mounted) return;

    await connectWalletModal(
      context: context,
      url: jsData.url,
      onConfirm: () async {
        try {
          final accountDetail = await coin
              .importData(WalletService.getActiveKey(walletImportType)!.data);
          await _sendResponse(jsData.id, {
            'address': sendingAddress,
            'publicKey': accountDetail.publicKey,
          });
          await saveWeb3Address('stacks', sendingAddress);
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected connection', jsData.id);
        _pop();
      },
    );
  }

  // ── signMessage ───────────────────────────────────────────────────────────

  Future<void> _signMessage(
    _StacksMessage jsData,
    StacksCoin coin,
    AccountData accountDetail,
  ) async {
    final rawMessage = (jsData.object['message'] as String?) ?? '';

    if (!context.mounted) return;

    await signMessage(
      context: context,
      messageType: personalSignKey,
      data: rawMessage,
      networkIcon: null,
      name: null,
      onConfirm: () async {
        try {
          final sigBytes = await coin.signMessage(rawMessage);
          await _sendResponse(jsData.id, {
            'signature': HEX.encode(sigBytes),
            'publicKey': accountDetail.publicKey,
          });
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected signature', jsData.id);
        _pop();
      },
    );
  }

  // ── signTransaction (native STX transfer) ─────────────────────────────────

  Future<void> _signTransaction(
    _StacksMessage jsData,
    StacksCoin coin,
    String sendingAddress,
  ) async {
    final obj = jsData.object;
    final to = obj['recipient'] as String? ?? obj['to'] as String? ?? '';
    final amount =
        (obj['amount'] as String?) ?? (obj['value'] as String?) ?? '0';
    final memo = obj['memo'] as String?;

    if (!context.mounted) return;

    // Re-use the generic EVM-style sign panel with STX-specific fields.
    // For a richer UI you can create a dedicated signStacksTransaction widget.
    await signMessage(
      context: context,
      messageType: '',
      data: 'Send $amount µSTX\nTo: $to${memo != null ? '\nMemo: $memo' : ''}',
      networkIcon: null,
      name: 'STX Transfer',
      onConfirm: () async {
        try {
          // Convert µSTX string to display STX
          final displayAmount = (BigInt.tryParse(amount) ?? BigInt.zero) /
              BigInt.from(stacksMicroPerStx);
          final txHash = await coin.transferToken(
            displayAmount.toString(),
            to,
            memo: memo,
          );
          await _sendResponse(jsData.id, {'txHash': txHash ?? ''});
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected transaction', jsData.id);
        _pop();
      },
    );
  }

  // ── signSIP010Transfer ────────────────────────────────────────────────────

  Future<void> _signSIP010Transfer(
    _StacksMessage jsData,
    String sendingAddress,
  ) async {
    final obj = jsData.object;

    final contractAddress = obj['contractAddress'] as String? ?? '';
    final contractName = obj['contractName'] as String? ?? '';
    final to = obj['recipient'] as String? ?? '';
    final amount = obj['amount'] as String? ?? '0';
    final memo = obj['memo'] as String?;

    // 1. Try the known hardcoded list first.
    final allSip010 = getSIP010Coins();
    SIP010Coin? tokenCoin = allSip010.cast<SIP010Coin?>().firstWhere(
          (c) =>
              c!.contractAddress == contractAddress &&
              c.contractName == contractName,
          orElse: () => null,
        );

    // 2. Not in the known list — build an ad-hoc coin from dApp-supplied params.
    //    The dApp must provide `symbol` and `decimals`; everything else is optional.
    if (tokenCoin == null) {
      final symbol = obj['symbol'] as String?;
      final decimals = (obj['decimals'] as num?)?.toInt();

      if (contractAddress.isEmpty ||
          contractName.isEmpty ||
          symbol == null ||
          symbol.isEmpty ||
          decimals == null) {
        await _sendError(
          'Unknown token $contractAddress.$contractName — '
          'provide symbol and decimals to transfer an unregistered SIP-010 token',
          jsData.id,
        );
        return;
      }

      final baseCoin = getStacksBlockchains().first;
      tokenCoin = SIP010Coin(
        isTestnet: baseCoin.isTestnet,
        derivationPath: baseCoin.derivationPath,
        blockExplorer: baseCoin.blockExplorer,
        symbol: symbol,
        default_: baseCoin.default_,
        image: obj['image'] as String? ?? baseCoin.image,
        name: obj['name'] as String? ?? symbol,
        geckoID: obj['geckoID'] as String? ?? '',
        rampID: '',
        payScheme: baseCoin.payScheme,
        contractAddress: contractAddress,
        contractName: contractName,
        mintDecimals: decimals,
      );
    }

    if (!context.mounted) return;

    await signMessage(
      context: context,
      messageType: '',
      data: 'Send $amount ${tokenCoin.symbol}\n'
          'Contract: ${tokenCoin.tokenAddress()}\n'
          'To: $to'
          '${memo != null ? '\nMemo: $memo' : ''}',
      networkIcon: null,
      name: '${tokenCoin.symbol} Transfer',
      onConfirm: () async {
        try {
          final txHash = await tokenCoin?.transferToken(
            amount,
            to,
            memo: memo,
          );
          await _sendResponse(jsData.id, {'txHash': txHash ?? ''});
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected transaction', jsData.id);
        _pop();
      },
    );
  }

  // ── JS response helpers ───────────────────────────────────────────────────

  Future<void> _sendResponse(int id, Map<String, dynamic> result) =>
      sendCustom('window.stacks.sendResponse($id, ${json.encode(result)})');

  Future<void> _sendError(String message, int id) => sendCustom(
      'window.stacks.sendError($id, "${message.replaceAll('"', "'")}") ');

  // ── Misc helpers ──────────────────────────────────────────────────────────

  void _pop() {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

// ─── Message model ────────────────────────────────────────────────────────────

class _StacksMessage {
  final int id;
  final String name;
  final Map<String, dynamic> object;
  final String? url;

  const _StacksMessage({
    required this.id,
    required this.name,
    required this.object,
    this.url,
  });

  factory _StacksMessage.fromJson(Map<String, dynamic> json) => _StacksMessage(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        object: (json['object'] as Map<String, dynamic>?) ?? {},
        url: json['url'] as String?,
      );
}
