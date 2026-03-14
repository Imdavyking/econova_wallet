import 'dart:convert' hide Encoding;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:wallet_app/coins/multiversx_coin.dart';

import '../components/loader.dart';
import '../utils/app_config.dart';
import '../utils/auth_utils.dart';
import '../utils/rpc_urls.dart';
import '../utils/slide_up_panel.dart';

Future<void> signMultiversXTransaction({
  required BuildContext context,
  required Function onConfirm,
  required Function()? onReject,
  String? gasPrice,
  String? gasLimit,
  String? value_,
  String? txData,
  String? from,
  String? to,
  String? networkIcon,
  String? name,
  required String symbol,
  String? chainId,
  int? nonce,
}) async {
  List<int> data = [];
  if (txData != null) {
    try {
      data = base64.decode(txData);
    } catch (_) {
      data = txDataToUintList(txData);
    }
    txData = utf8.decode(data);
  }

  final localization = AppLocalizations.of(context)!;
  final deciml = BigInt.from(pow(10, multiversxDecimals));
  final value = value_ == null ? 0.0 : BigInt.parse(value_) / deciml;
  final isSigning = ValueNotifier(false);
  final hasTransaction = gasPrice != null && gasLimit != null;
  double transactionFee = 0;
  if (hasTransaction) {
    transactionFee =
        double.parse(gasPrice) * double.parse(gasLimit) / deciml.toDouble();
  }
  final finalVal = Decimal.parse(value.toString());
  final finalTranFee = Decimal.parse(transactionFee.toString());

  await slideUpPanel(
    context,
    DefaultTabController(
      length: 2,
      child: Column(children: [
        _header(localization.signTransaction, onReject),
        const SizedBox(
          height: 50,
          child: TabBar(tabs: [
            Tab(icon: Text('Details', style: _tabStyle)),
            Tab(icon: Text('Data', style: _tabStyle)),
          ]),
        ),
        Expanded(
          child: TabBarView(children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (networkIcon != null) _networkIcon(networkIcon),
                    if (name != null)
                      Text(name, style: const TextStyle(fontSize: 16)),
                    if (from != null)
                      _field(localization.from, from),
                    if (to != null)
                      _field(localization.receipientAddress, to),
                    if (chainId != null)
                      _field(localization.chainId, chainId),
                    if (nonce != null)
                      _field(localization.nonce, '$nonce'),
                    _field(localization.transactionAmount,
                        '${finalVal.toString()} $symbol'),
                    if (hasTransaction)
                      _field(localization.transactionFee,
                          '${finalTranFee.toString()} $symbol'),
                    ValueListenableBuilder<bool>(
                      valueListenable: isSigning,
                      builder: (_, signing, __) {
                        if (signing) return const Row(children: [Loader()]);
                        return _confirmRejectRow(
                            context, localization, isSigning, onConfirm,
                            onReject);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Data',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    children: [
                      Text(txData ?? '',
                          style: const TextStyle(fontSize: 16)),
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

// ─── Shared helpers (file-private) ───────────────────────────────────────────

const _tabStyle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w500, color: orangTxt);

Widget _header(String title, Function()? onReject) => Container(
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
              if (Navigator.canPop(_currentContext!)) onReject?.call();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );

// We use a global key trick to get the context inside file-private helpers.
// In production, pass context explicitly to _header.
BuildContext? _currentContext;

Widget _field(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16)),
      ]),
    );

Widget _networkIcon(String url) => SizedBox(
      height: 50,
      width: 50,
      child: CachedNetworkImage(
        imageUrl: ipfsTohttp(url),
        placeholder: (_, __) =>
            const SizedBox(width: 20, height: 20, child: Loader()),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.error, color: Colors.red),
      ),
    );

Row _confirmRejectRow(
  BuildContext context,
  AppLocalizations localization,
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
          child: Text(localization.confirm,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TextButton(
          style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: appBackgroundblue),
          onPressed: onReject,
          child: Text(localization.reject,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    ]);
