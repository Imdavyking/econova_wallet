import 'dart:convert';
import 'dart:math';

import 'package:bs58check/bs58check.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:solana/dto.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart' as solana;
import 'package:wallet_app/coins/solana_coin.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/model/sol_token_info.dart';
import 'package:wallet_app/model/solana_transaction_legacy.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
// ignore: implementation_imports
import 'package:solana/src/encoder/instruction.dart' as encoder;

/// Holds the result of a Solana transaction simulation: the estimated fee
/// (in SOL) and a human-readable list of balance changes / actions.
class SolanaSimuRes {
  final double fee;
  final List<String> result;

  const SolanaSimuRes({
    required this.fee,
    required this.result,
  });
}

// ─── Constants ────────────────────────────────────────────────────────────────

/// Base fee per signature, in lamports.
const int _lamportsPerSignature = 5000;

// ─── Simulation ───────────────────────────────────────────────────────────────

/// Simulates a legacy Solana transaction and returns the estimated fee and a
/// list of human-readable balance-change descriptions.
///
/// Known fixes vs. the original implementation:
///  1. Fee: was `0.000005 / pow(10, solDecimals)` (double-divides by 1 SOL).
///     Now: `signerCount * _lamportsPerSignature / pow(10, solDecimals)`.
///  2. SOL balance: `getBalance` returns `Future<int>` — the original cast it
///     directly to `int`, silently storing the Future object reference. Now
///     awaited before entering the `putIfAbsent` call.
///  3. Signer count: the original incremented a counter for every signer key
///     across every instruction, causing duplicate-counting for keys that
///     appear in multiple instructions. Now tracked as a `Set<String>` of
///     unique pubkeys.
Future<SolanaSimuRes> dappSimulateTrx(
  SolanaTransactionLegacy solanaWeb3Res,
  solana.Ed25519HDKeyPair solanaKeyPair,
  SolanaCoin coin,
  String symbol,
  int solDecimals,
) async {
  final blockHash = solanaWeb3Res.recentBlockhash;
  final instructions = solanaWeb3Res.instructions ?? [];

  // Fix #3 — unique signer pubkeys, not a raw increment per instruction-key.
  final signerPubkeys = <String>{};
  int totalLamportsDiff = 0;
  final List<String> simulationActions = [];
  final Map<String, int> tokenBalances = {};

  for (final instruct in instructions) {
    final keys = instruct.keys!;
    final List<encoder.Instruction> encodedInstructions = [];
    final List<String> accountPubkeys = [];
    final List<AccountMeta> accountMetas = [];

    for (final key in keys) {
      if (key.isSigner) signerPubkeys.add(key.pubkey); // Fix #3
      accountPubkeys.add(key.pubkey);
      final pubKey = solana.Ed25519HDPublicKey.fromBase58(key.pubkey);
      accountMetas.add(
        AccountMeta(
          pubKey: pubKey,
          isSigner: key.isSigner,
          isWriteable: key.isWritable,
        ),
      );
    }

    final programId = instruct.programId;
    encodedInstructions.add(
      encoder.Instruction(
        programId: solana.Ed25519HDPublicKey.fromBase58(programId),
        accounts: accountMetas,
        data: ByteArray.fromBase58(
          base58.encode(Uint8List.fromList(instruct.data!.data!)),
        ),
      ),
    );

    final compiledMessage =
        solana.Message(instructions: encodedInstructions).compile(
      recentBlockhash: blockHash,
      feePayer: solanaKeyPair.publicKey,
    );

    final fees = await coin.getProxy().rpcClient.getFeeForMessage(
          base64.encode(compiledMessage.toByteArray().toList()),
          commitment: solana.Commitment.processed,
        );

    try {
      final tx = await solanaKeyPair.signMessage(
        recentBlockhash: blockHash,
        message: solana.Message(instructions: encodedInstructions),
      );
      final simResult = await coin.getProxy().rpcClient.simulateTransaction(
            tx.encode(),
            commitment: solana.Commitment.processed,
            accounts: SimulateTransactionAccounts(
              encoding: Encoding.base58,
              addresses: accountPubkeys,
            ),
          );

      final value = simResult.value;
      if (value.err != null) throw Exception(value.err.toString());

      final accountsResult = value.accounts;
      if (accountsResult == null || accountsResult.isEmpty) continue;

      for (int i = 0; i < accountsResult.length; i++) {
        final account = accountsResult[i];
        if (account.data is! BinaryAccountData) continue;
        final accountData = account.data as BinaryAccountData;

        if (solana.TokenProgram.programId == account.owner) {
          if (accountData.data.length != 165) continue;

          final tokenInfo = SolTokenInfo.decode(account);
          if (tokenInfo.authority != solanaKeyPair.publicKey) continue;

          final cacheKey = '${tokenInfo.authority}${tokenInfo.mint}';
          if (!tokenBalances.containsKey(cacheKey)) {
            final tokenAmt = await coin.getProxy().getTokenBalance(
                  owner: tokenInfo.authority,
                  mint: tokenInfo.mint,
                  commitment: Commitment.processed,
                );
            tokenBalances[cacheKey] = int.parse(tokenAmt.amount);
          }

          final tokenAmt = await coin.getProxy().getTokenBalance(
                owner: tokenInfo.authority,
                mint: tokenInfo.mint,
                commitment: Commitment.processed,
              );
          final diff = (tokenInfo.balance - tokenBalances[cacheKey]!) /
              pow(10, tokenAmt.decimals);

          if (diff != 0) {
            simulationActions.add(
              '${diff > 0 ? '+' : ''}$diff ${tokenInfo.mint.toBase58()}',
            );
          } else if (tokenInfo.delegateAmt != 0) {
            simulationActions.add(
              'Approve ${tokenInfo.delegateAmt / pow(10, tokenAmt.decimals)}'
              ' ${tokenInfo.mint} to ${tokenInfo.delegate}',
            );
          }
        } else if (solana.SystemProgram.programId == account.owner) {
          if (accountPubkeys[i] != solanaKeyPair.address) continue;

          final balanceCacheKey = '${solanaKeyPair.address}${account.owner}';

          if (!tokenBalances.containsKey(balanceCacheKey)) {
            // Fix #2 — await the Future before storing in the map.
            final currentLamports = await coin.getProxy().rpcClient.getBalance(
                  solanaKeyPair.address,
                  commitment: solana.Commitment.processed,
                );
            tokenBalances[balanceCacheKey] = currentLamports.value;
          }

          totalLamportsDiff +=
              account.lamports - tokenBalances[balanceCacheKey]! + (fees ?? 0);
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Simulation error: $e');
        debugPrint(stack.toString());
      }
    }
  }

  final solDiff = totalLamportsDiff / pow(10, solDecimals);
  if (solDiff != 0) {
    simulationActions.add('${solDiff > 0 ? '+' : ''}$solDiff $symbol');
  }

  // Fix #1 — fee is lamports-per-signature × unique-signers, converted to SOL.
  final fee =
      signerPubkeys.length * _lamportsPerSignature / pow(10, solDecimals);

  return SolanaSimuRes(fee: fee, result: simulationActions);
}

// ─── UI ───────────────────────────────────────────────────────────────────────

Widget buildSignTransactionUI({
  required BuildContext context,
  required String from,
  required String? networkIcon,
  required String? name,
  required String symbol,
  required String? txData,
  required SolanaSimuRes simulationResult,
  required ValueNotifier<bool> isSigning,
  required VoidCallback onConfirm,
  required VoidCallback onReject,
}) {
  final localization = AppLocalizations.of(context)!;

  return Column(
    children: [
      _Header(localization: localization, onReject: onReject),
      _tabBar(),
      Expanded(
        child: TabBarView(
          children: [
            _DetailsTab(
              from: from,
              networkIcon: networkIcon,
              name: name,
              symbol: symbol,
              simulationResult: simulationResult,
              isSigning: isSigning,
              onConfirm: () async {
                if (await authenticate(context)) {
                  isSigning.value = true;
                  try {
                    onConfirm();
                  } catch (_) {}
                  isSigning.value = false;
                } else {
                  onReject();
                }
              },
              onReject: onReject,
              localization: localization,
            ),
            _RawTab(txData: txData ?? ''),
          ],
        ),
      ),
    ],
  );
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AppLocalizations localization;
  final VoidCallback onReject;

  const _Header({required this.localization, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            localization.signTransaction,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          IconButton(
            onPressed: Navigator.canPop(context) ? onReject : null,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

Widget _tabBar() => const SizedBox(
      height: 50,
      child: TabBar(
        tabs: [
          Tab(
            child: Text(
              'Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: orangTxt,
              ),
            ),
          ),
          Tab(
            child: Text(
              'Raw',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: orangTxt,
              ),
            ),
          ),
        ],
      ),
    );

class _DetailsTab extends StatelessWidget {
  final String from;
  final String? networkIcon;
  final String? name;
  final String symbol;
  final SolanaSimuRes simulationResult;
  final ValueNotifier<bool> isSigning;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final AppLocalizations localization;

  const _DetailsTab({
    required this.from,
    required this.networkIcon,
    required this.name,
    required this.symbol,
    required this.simulationResult,
    required this.isSigning,
    required this.onConfirm,
    required this.onReject,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (networkIcon != null) ...[
            SizedBox(
              height: 50,
              width: 50,
              child: CachedNetworkImage(
                imageUrl: ipfsTohttp(networkIcon!),
                placeholder: (_, __) => const Loader(color: appPrimaryColor),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (name != null) ...[
            Text(name!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
          ],
          _LabelValue(label: localization.from, value: from),
          const SizedBox(height: 16),
          ...simulationResult.result.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LabelValue(label: localization.action, value: action),
            ),
          ),
          const SizedBox(height: 16),
          _LabelValue(
            label: localization.transactionFee,
            value: '${simulationResult.fee} $symbol',
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: isSigning,
            builder: (_, signing, __) => signing
                ? const Center(child: Loader())
                : _ActionButtons(
                    onConfirm: onConfirm,
                    onReject: onReject,
                    localization: localization,
                  ),
          ),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final AppLocalizations localization;

  const _ActionButtons({
    required this.onConfirm,
    required this.onReject,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: appBackgroundblue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
    const labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18.0,
    );
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: buttonStyle,
            child: Text(localization.confirm, style: labelStyle),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onReject,
            style: buttonStyle,
            child: Text(localization.reject, style: labelStyle),
          ),
        ),
      ],
    );
  }
}

class _RawTab extends StatelessWidget {
  final String txData;

  const _RawTab({required this.txData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: SelectableText(txData),
    );
  }
}
