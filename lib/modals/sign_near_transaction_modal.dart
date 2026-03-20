import 'dart:convert' hide Encoding;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:hex/hex.dart';
import 'package:near_api_flutter/near_api_flutter.dart';

import '../coins/near_coin.dart';
import '../components/loader.dart';
import '../model/near_trx_obj.dart' as near_obj;
import '../utils/app_config.dart';
import '../utils/auth_utils.dart';
import '../utils/rpc_urls.dart';
import '../utils/slide_up_panel.dart';

Future<void> signNearTransaction({
  required BuildContext context,
  required Function onConfirm,
  required Function()? onReject,
  required NearCoin coin,
  required near_obj.NearDappTrx txData,
  required String from,
  required String symbol,
  String? networkIcon,
  String? name,
}) async {
  final localization = AppLocalizations.of(context)!;
  final isSigning = ValueNotifier(false);

  slideUpPanel(
    context,
    DefaultTabController(
      length: 3,
      child: Column(children: [
        _nearHeader(localization.signTransaction, onReject),
        const SizedBox(
          height: 50,
          child: TabBar(tabs: [
            Tab(
                icon: Text('Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: orangTxt))),
            Tab(
                icon: Text('Data',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: orangTxt))),
            Tab(
                icon: Text('Hex',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: orangTxt))),
          ]),
        ),
        Expanded(
          child: TabBarView(children: [
            // ── Details ─────────────────────────────────────────────────
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (networkIcon != null) _nearIcon(networkIcon),
                    if (name != null)
                      Text(name, style: const TextStyle(fontSize: 16)),
                    _nearField(localization.from, txData.signerId),
                    _nearField(
                        localization.receipientAddress, txData.receiverId),
                    _nearField(localization.nonce, '${txData.nonce}'),
                    ..._buildNearActionUi(
                        txData: txData, localization: localization, coin: coin),
                    ValueListenableBuilder<bool>(
                      valueListenable: isSigning,
                      builder: (_, signing, __) {
                        if (signing) return const Row(children: [Loader()]);
                        return _nearButtons(context, localization, isSigning,
                            onConfirm, onReject);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Data ────────────────────────────────────────────────────
            const SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [SizedBox(height: 20)]),
              ),
            ),

            // ── Hex ─────────────────────────────────────────────────────
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Hex',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    children: [
                      Text(
                        txData.encoded != null
                            ? HEX.encode(txData.encoded!)
                            : '0x',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    ),
    canDismiss: false,
  );
}

// ─── NEAR action UI ───────────────────────────────────────────────────────────

class _NearUiAmount {
  final BigInt nearAmount;
  final double tokenAmount;
  final String message;
  final String? functionName;
  const _NearUiAmount({
    required this.nearAmount,
    required this.tokenAmount,
    required this.message,
    this.functionName,
  });
}

List<Widget> _buildNearActionUi({
  required near_obj.NearDappTrx txData,
  required AppLocalizations localization,
  required NearCoin coin,
}) {
  return txData.actions.map((near_obj.Action action) {
    final actionType = ActionType.getByValue(action.value);
    return FutureBuilder<_NearUiAmount>(
      future: () async {
        BigInt nearAmount = BigInt.zero;
        double tokenAmount = 0;
        String message = '';
        String functionName = '';

        if (action is near_obj.Transfer) {
          nearAmount = action.deposit;
        } else if (action is near_obj.FunctionCall) {
          nearAmount = action.deposit;
          functionName = '(${action.methodName})';
          if (action.methodName == 'ft_transfer') {
            final args = json.decode(ascii.decode(action.args));
            final meta = await coin.getMetaData(txData.receiverId);
            tokenAmount = BigInt.parse(args['amount']) /
                BigInt.from(10).pow(meta!.decimals);
            message =
                'Transfer $tokenAmount ${meta.symbol} (${txData.receiverId}) to ${args['receiver_id']}';
          }
        } else if (action is near_obj.Stake) {
          nearAmount = action.stake;
        }
        return _NearUiAmount(
            nearAmount: nearAmount,
            tokenAmount: tokenAmount,
            message: message,
            functionName: functionName);
      }(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text(localization.couldNotFetchData,
                  style: const TextStyle(fontSize: 16)));
        }
        if (!snapshot.hasData) return const Center(child: Loader());
        final d = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(localization.action,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('${actionType.name} ${d.functionName ?? ''}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(localization.amount,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('${d.nearAmount / BigInt.from(10).pow(nearDecimals)} NEAR',
                style: const TextStyle(fontSize: 16)),
            if (action is near_obj.FunctionCall &&
                action.methodName == 'ft_transfer') ...[
              const SizedBox(height: 8),
              Text(localization.info,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(d.message, style: const TextStyle(fontSize: 16)),
            ],
          ]),
        );
      },
    );
  }).toList();
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _nearHeader(String title, Function()? onReject) => Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const IconButton(
              onPressed: null,
              icon: Icon(Icons.close, color: Colors.transparent)),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          IconButton(
            onPressed: () {
              if (Navigator.canPop(_nearCtx!)) onReject?.call();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );

BuildContext? _nearCtx;

Widget _nearField(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16)),
      ]),
    );

Widget _nearIcon(String url) => SizedBox(
      height: 50,
      width: 50,
      child: CachedNetworkImage(
        imageUrl: ipfsTohttp(url),
        placeholder: (_, __) =>
            const SizedBox(width: 20, height: 20, child: Loader()),
        errorWidget: (_, __, ___) => const Icon(Icons.error, color: Colors.red),
      ),
    );

Row _nearButtons(
  BuildContext context,
  AppLocalizations loc,
  ValueNotifier<bool> isSigning,
  Function onConfirm,
  Function()? onReject,
) =>
    Row(children: [
      Expanded(
        child: TextButton(
          style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: appBackgroundblue),
          onPressed: () async {
            if (await authenticate(context)) {
              isSigning.value = true;
              try {
                await onConfirm();
              } catch (_) {}
              isSigning.value = false;
            } else {
              onReject?.call();
            }
          },
          child: Text(loc.confirm,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TextButton(
          style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: appBackgroundblue),
          onPressed: onReject,
          child: Text(loc.reject,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    ]);
