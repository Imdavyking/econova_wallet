import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:bs58check/bs58check.dart';
import 'package:solana/solana.dart' as solana;
import 'package:solana/encoder.dart';
import 'package:wallet_app/main.dart';

import '../coins/solana_coin.dart';
import '../utils/json_model_callback.dart';
import '../model/solana_transaction_legacy.dart';
import '../model/solana_transaction_versioned.dart';
import '../components/sign_solana_ui.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import '../utils/slide_up_panel.dart';
import 'base_handler.dart';

/// Handles all `solana`-related JS bridge calls.
class SolanaHandler extends BaseWebViewHandler {
  SolanaHandler({required super.context});

  @override
  void registerHandlers() {
    // Dispatched by CryptoHandler when jsData.network == 'solana'
  }

  Future<void> handle(JsCallbackModel jsData) async {
    final coin = getSolanaBlockChains().first;
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final accountDetail = await coin.importData(data);
    final privateKeyBytes = HEX.decode(accountDetail.privateKey!);
    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: privateKeyBytes);
    final sendingAddress = accountDetail.address;

    switch (jsData.name) {
      case 'requestAccounts':
        await _requestAccounts(jsData, sendingAddress, keyPair);
        break;
      case 'signMessage':
        await _signMessage(jsData, keyPair);
        break;
      case 'signRawTransaction':
        await _signRawTransaction(jsData, coin, keyPair);
        break;
      default:
        sendError('solana', 'Operation not supported', jsData.id ?? 0);
    }
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _requestAccounts(JsCallbackModel jsData, String sendingAddress,
      solana.Ed25519HDKeyPair keyPair) async {
    final existing = await getWeb3Address('solana', sendingAddress);
    if (existing != null) {
      await _setSolanaAddress(jsData.id, sendingAddress);
      return;
    }
    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: jsData.url,
      onConfirm: () async {
        try {
          await _setSolanaAddress(jsData.id, sendingAddress);
          await saveWeb3Address('solana', sendingAddress);
        } catch (e) {
          sendError(
              'solana', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        sendError('solana', 'user rejected connection', jsData.id ?? 0);
        _pop();
      },
    );
  }

  Future<void> _signMessage(
      JsCallbackModel jsData, solana.Ed25519HDKeyPair keyPair) async {
    try {
      final data = JsSolanaMessageObject.fromJson(jsData.object ?? {});
      if (!context.mounted) return;
      await signMessage(
        context: context,
        messageType: personalSignKey,
        data: data.data,
        networkIcon: null,
        name: null,
        onConfirm: () async {
          try {
            final sig = await keyPair.sign(txDataToUintList(data.data));
            sendResponse('solana', base58.encode(sig.bytes as Uint8List),
                jsData.id ?? 0);
          } catch (e) {
            sendError(
                'solana', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
          } finally {
            _pop();
          }
        },
        onReject: () {
          sendError('solana', 'user rejected signature', jsData.id ?? 0);
          _pop();
        },
      );
    } catch (e) {
      sendError('solana', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
    }
  }

  Future<void> _signRawTransaction(JsCallbackModel jsData, SolanaCoin coin,
      solana.Ed25519HDKeyPair keyPair) async {
    final data = JsSolanaTransactionObject.fromJson(jsData.object ?? {});
    final Map<String, dynamic> decodedData = json.decode(data.data);

    final messageB64 = base64.encode(base58.decode(data.raw));
    final signature = await keyPair.sign(base58.decode(data.raw));
    final fee = await coin.getFeeForMessage(messageB64);

    late solana.Ed25519HDPublicKey from;
    late SolanaSimuRes simulationResult;

    if (decodedData.containsKey('message')) {
      final versioned = SolanaTransactionVersioned.fromJson(decodedData);
      from = solana.Ed25519HDPublicKey.fromBase58(
          versioned.message.staticAccountKeys.first);
      simulationResult = SolanaSimuRes(
        fee: fee / pow(10, solDecimals),
        result: coin.dappTrxVersionedResult(versioned),
      );
    } else {
      final legacy = SolanaTransactionLegacy.fromJson(decodedData);
      from = solana.Ed25519HDPublicKey.fromBase58(legacy.feePayer);
      simulationResult = await dappSimulateTrx(
          legacy, keyPair, coin, coin.getSymbol(), solDecimals);
    }

    if (!context.mounted) return;
    final isSigning = ValueNotifier<bool>(false);
    await slideUpPanel(
      context,
      DefaultTabController(
        length: 2,
        child: buildSignTransactionUI(
          isSigning: isSigning,
          simulationResult: simulationResult,
          from: from.toBase58(),
          txData: data.raw,
          networkIcon: null,
          context: context,
          symbol: 'SOL',
          name: '',
          onConfirm: () async {
            try {
              sendResponse('solana', signature.toBase58(), jsData.id ?? 0);
            } catch (e) {
              if (kDebugMode) print(e);
              sendError(
                  'solana', e.toString().replaceAll('"', "'"), jsData.id ?? 0);
            } finally {
              _pop();
            }
          },
          onReject: () async {
            sendError('solana', 'user rejected transaction', jsData.id ?? 0);
            _pop();
          },
        ),
      ),
      canDismiss: false,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _setSolanaAddress(dynamic id, String address) async {
    await sendCustom('''
if (typeof trustwallet !== "undefined" && 
    typeof trustwallet.solana !== "undefined" && 
    typeof trustwallet.solana.setAddress === "function") {
  trustwallet.solana.setAddress("$address");
} else {
  console.warn("trustwallet.solana.setAddress is not defined");
}
''');
    await sendCustom('trustwallet.solana.sendResponse($id, ["$address"])');
  }

  void _pop() {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
