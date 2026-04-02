import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bs58check/bs58check.dart';
import 'package:hex/hex.dart';
import 'package:solana/solana.dart' as solana;
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

/// Handles all `solana`-related JS bridge calls dispatched by [CryptoHandler].
class SolanaHandler extends BaseWebViewHandler {
  SolanaHandler({required super.context});

  @override
  void registerHandlers() {
    // Dispatched by CryptoHandler when jsData.network == 'solana'.
  }

  // ─── Public entry point ─────────────────────────────────────────────────────

  Future<void> handle(JsCallbackModel jsData) async {
    final coin = getSolanaBlockChains().first;
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final accountDetail = await coin.importData(data);
    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: HEX.decode(accountDetail.privateKey!),
    );

    switch (jsData.name) {
      case 'requestAccounts':
        await _requestAccounts(jsData, accountDetail.address);
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

  // ─── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _requestAccounts(
    JsCallbackModel jsData,
    String address,
  ) async {
    // If the user already approved this origin, respond immediately.
    final existing = await getWeb3Address('solana', address);
    if (existing != null) {
      await _setSolanaAddress(jsData.id, address);
      return;
    }

    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: jsData.url,
      onConfirm: () async {
        try {
          await _setSolanaAddress(jsData.id, address);
          await saveWeb3Address('solana', address);
        } catch (e) {
          sendError('solana', _sanitize(e), jsData.id ?? 0);
        } finally {
          _pop();
        }
      },
      onReject: () {
        sendError('solana', 'user rejected connection', jsData.id ?? 0);
        _pop();
      },
    );
  }

  Future<void> _signMessage(
    JsCallbackModel jsData,
    solana.Ed25519HDKeyPair keyPair,
  ) async {
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
            sendResponse(
              'solana',
              base58.encode(sig.bytes as Uint8List),
              jsData.id ?? 0,
            );
          } catch (e) {
            sendError('solana', _sanitize(e), jsData.id ?? 0);
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
      sendError('solana', _sanitize(e), jsData.id ?? 0);
    }
  }

  Future<void> _signRawTransaction(
    JsCallbackModel jsData,
    SolanaCoin coin,
    solana.Ed25519HDKeyPair keyPair,
  ) async {
    try {
      final data = JsSolanaTransactionObject.fromJson(jsData.object ?? {});
      final txBytes = Uint8List.fromList(base58.decode(data.raw));

      // Derive fee-payer from the serialized bytes — no dependency on the
      // decoded JSON model for account resolution.
      final (fromAddr, _) = SolanaCoin.extractFromTo(txBytes);
      final from = fromAddr ?? keyPair.publicKey.toBase58();

      // Fee estimation.
      final fee = await coin.getFeeForMessage(base64.encode(txBytes));

      // Simulation — versioned txs get a summary only; legacy gets full sim.
      final simulationResult = await _buildSimulationResult(
        rawJson: data.data,
        txBytes: txBytes,
        fee: fee,
        coin: coin,
        keyPair: keyPair,
      );

      if (!context.mounted) return;
      final isSigning = ValueNotifier<bool>(false);

      await slideUpPanel(
        context,
        DefaultTabController(
          length: 2,
          child: buildSignTransactionUI(
            isSigning: isSigning,
            simulationResult: simulationResult,
            from: from,
            txData: data.raw,
            networkIcon: null,
            context: context,
            symbol: 'SOL',
            name: '',
            onConfirm: () async {
              try {
                // signVersionTx handles both legacy and versioned correctly.
                final signedBytes = await coin.signVersionTx(txBytes);
                sendResponse(
                  'solana',
                  base58.encode(Uint8List.fromList(signedBytes)),
                  jsData.id ?? 0,
                );
              } catch (e) {
                sendError('solana', _sanitize(e), jsData.id ?? 0);
              } finally {
                _pop();
              }
            },
            onReject: () {
              sendError('solana', 'user rejected transaction', jsData.id ?? 0);
              _pop();
            },
          ),
        ),
        canDismiss: false,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[SolanaHandler] _signRawTransaction: $e');
      sendError('solana', _sanitize(e), jsData.id ?? 0);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Builds [SolanaSimuRes] from [rawJson].
  /// Versioned transactions: returns a summary from the decoded model without
  /// on-chain simulation (not supported for versioned messages).
  /// Legacy transactions: runs full on-chain simulation.
  Future<SolanaSimuRes> _buildSimulationResult({
    required String rawJson,
    required Uint8List txBytes,
    required int fee,
    required SolanaCoin coin,
    required solana.Ed25519HDKeyPair keyPair,
  }) async {
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    if (decoded.containsKey('message')) {
      final versioned = SolanaTransactionVersioned.fromJson(decoded);
      return SolanaSimuRes(
        fee: fee / pow(10, solDecimals),
        result: coin.dappTrxVersionedResult(versioned),
      );
    }

    final legacy = SolanaTransactionLegacy.fromJson(decoded);
    return dappSimulateTrx(
        legacy, keyPair, coin, coin.getSymbol(), solDecimals);
  }

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

  /// Strips double-quotes from exception messages before sending over the
  /// JS bridge (unescaped quotes break the JSON payload).
  String _sanitize(Object e) => e.toString().replaceAll('"', "'");
}
