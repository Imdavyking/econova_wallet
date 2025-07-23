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

class SolanaSimuRes {
  final double fee;
  final List<String> result;

  const SolanaSimuRes({
    required this.fee,
    required this.result,
  });
}

Future<SolanaSimuRes> dappSimulateTrx(
  SolanaTransactionLegacy solanaWeb3Res,
  solana.Ed25519HDKeyPair solanaKeyPair,
  SolanaCoin coin,
  String symbol,
  int solDecimals,
) async {
  final blockHash = solanaWeb3Res.recentBlockhash;
  final instructions = solanaWeb3Res.instructions!;
  int signers = 0;
  int totalSolDiff = 0;
  List<String> simulationAction = [];
  Map<String, int> tokenBalances = {};

  for (final instruct in instructions) {
    final keys = instruct.keys!;
    List<encoder.Instruction> instructionsList = [];
    List<String> accountsPub = [];
    List<AccountMeta> accounts = [];

    for (final key in keys) {
      final pubKeyStr = key.pubkey;
      if (key.isSigner) signers++;
      accountsPub.add(pubKeyStr);
      final pubKey = solana.Ed25519HDPublicKey.fromBase58(pubKeyStr);

      accounts.add(
        key.isWritable
            ? AccountMeta(
                pubKey: pubKey,
                isSigner: key.isSigner,
                isWriteable: true,
              )
            : AccountMeta(
                pubKey: pubKey,
                isSigner: key.isSigner,
                isWriteable: false,
              ),
      );
    }

    final instructData = instruct.data!.data!;
    final programId = instruct.programId;

    instructionsList.add(
      encoder.Instruction(
        programId: solana.Ed25519HDPublicKey.fromBase58(programId),
        accounts: accounts,
        data: ByteArray.fromBase58(
          base58.encode(
            Uint8List.fromList(instructData),
          ),
        ),
      ),
    );

    final message = solana.Message(
      instructions: instructionsList,
    );

    final compiledMessage = message.compile(
      recentBlockhash: blockHash,
      feePayer: solanaKeyPair.publicKey,
    );

    final encodedMessage = compiledMessage.toByteArray().toList();

    final fees = await coin.getProxy().rpcClient.getFeeForMessage(
          base64.encode(encodedMessage),
          commitment: solana.Commitment.processed,
        );

    try {
      final tx = await solanaKeyPair.signMessage(
        recentBlockhash: blockHash,
        message: solana.Message(instructions: instructionsList),
      );
      final simResult = await coin.getProxy().rpcClient.simulateTransaction(
            tx.encode(),
            commitment: solana.Commitment.processed,
            accounts: SimulateTransactionAccounts(
              encoding: Encoding.base58,
              addresses: accountsPub,
            ),
          );

      final result = simResult.value;

      if (result.err != null) throw Exception(result.err.toString());

      final accountsResult = result.accounts;
      if (accountsResult != null && accountsResult.isNotEmpty) {
        int index = -1;
        for (final account in accountsResult) {
          index++;
          if (account.data is BinaryAccountData) {
            final accountData = account.data as BinaryAccountData;

            if (solana.TokenProgram.programId == account.owner) {
              if (accountData.data.length != 165) continue;

              final tokenInfo = SolTokenInfo.decode(account);

              if (tokenInfo.authority != solanaKeyPair.publicKey) continue;

              final key = '${tokenInfo.authority}${tokenInfo.mint}';

              final tokenAmt = await coin.getProxy().getTokenBalance(
                    owner: tokenInfo.authority,
                    mint: tokenInfo.mint,
                    commitment: Commitment.processed,
                  );

              tokenBalances.putIfAbsent(key, () => int.parse(tokenAmt.amount));

              final currentBalance = tokenBalances[key]!;
              final diff = tokenInfo.balance - currentBalance;
              final balanceDiff = diff / pow(10, tokenAmt.decimals);

              if (balanceDiff != 0) {
                simulationAction.add(
                  '${balanceDiff > 0 ? '+' : ''}$balanceDiff ${tokenInfo.mint.toBase58()}',
                );
              } else if (tokenInfo.delegateAmt != 0) {
                simulationAction.add(
                  'Approve ${tokenInfo.delegateAmt / pow(10, tokenAmt.decimals)} ${tokenInfo.mint} to ${tokenInfo.delegate}',
                );
              }
            } else if (solana.SystemProgram.programId == account.owner) {
              if (accountsPub[index] != solanaKeyPair.address) continue;

              final key = '${solanaKeyPair.address}${account.owner}';

              tokenBalances.putIfAbsent(
                  key,
                  () => coin.getProxy().rpcClient.getBalance(
                        solanaKeyPair.address,
                        commitment: solana.Commitment.processed,
                      ) as int);

              final getBalance = tokenBalances[key]!;

              totalSolDiff += account.lamports - getBalance + fees!;
            }
          }
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('Simulation error: $e');
        print(stack);
      }
    }
  }

  final balanceDiff = totalSolDiff / pow(10, solDecimals);
  if (balanceDiff != 0) {
    simulationAction.add('${balanceDiff > 0 ? '+' : ''}$balanceDiff $symbol');
  }

  final txFee = 0.000005 / pow(10, solDecimals);
  return SolanaSimuRes(fee: signers * txFee, result: simulationAction);
}

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
      // Header
      _buildHeader(context, localization, onReject),
      // Tab Bar
      _buildTabBar(),
      // Tab View
      Expanded(
        child: TabBarView(
          children: [
            _buildDetailsTab(
              context: context,
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
            _buildRawTab(txData ?? '0x'),
          ],
        ),
      )
    ],
  );
}

Widget _buildHeader(BuildContext context, AppLocalizations localization,
    VoidCallback onReject) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 48), // Placeholder for close button space
        Text(
          localization.signTransaction,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              onReject();
            }
          },
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  );
}

Widget _buildTabBar() {
  return const SizedBox(
    height: 50,
    child: TabBar(
      tabs: [
        Tab(
          icon: Text(
            "Details",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500, color: orangTxt),
          ),
        ),
        Tab(
          icon: Text(
            "Raw",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500, color: orangTxt),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailsTab({
  required BuildContext context,
  required String from,
  required String? networkIcon,
  required String? name,
  required String symbol,
  required SolanaSimuRes simulationResult,
  required ValueNotifier<bool> isSigning,
  required VoidCallback onConfirm,
  required VoidCallback onReject,
  required AppLocalizations localization,
}) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (networkIcon != null)
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.only(bottom: 8),
              child: CachedNetworkImage(
                imageUrl: ipfsTohttp(networkIcon),
                placeholder: (_, __) => const Loader(color: appPrimaryColor),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
          if (name != null)
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 16)),
          const SizedBox(height: 12),
          Text(localization.from,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(from, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ...simulationResult.result.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localization.action,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(action, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Text(localization.transactionFee,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('${simulationResult.fee} $symbol',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: isSigning,
            builder: (_, signing, __) {
              if (signing) {
                return const Center(child: Loader());
              }
              return Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onReject,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(localization.reject),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangTxt,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(localization.confirm),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildRawTab(String txData) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(25),
    child: Text(txData),
  );
}
