import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../components/loader.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import '../utils/slide_up_panel.dart';
import '../utils/starknet_call.dart';

Future<void> signStarkNetTransaction({
  required BuildContext context,
  required Function onConfirm,
  required Function()? onReject,
  required String from,
  required List<StarknetCall> dapCalls,
  String? networkIcon,
  String? name,
  String? symbol,
  String? title,
}) async {
  final localization = AppLocalizations.of(context)!;
  final isSigning = ValueNotifier(false);

  slideUpPanel(
    context,
    DefaultTabController(
      length: 3,
      child: Column(children: [
        _snHeader(localization.signTransaction, context, onReject),
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
            // ── Details — no async work, render directly ──────────────────
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (networkIcon != null) _snIcon(networkIcon),
                    if (name != null)
                      Text(name, style: const TextStyle(fontSize: 16)),
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                          child: StarknetCallList(dapCalls: dapCalls),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isSigning,
                      builder: (_, signing, __) {
                        if (signing) return const Row(children: [Loader()]);
                        return _snButtons(context, localization, isSigning,
                            onConfirm, onReject);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Data (empty) ──────────────────────────────────────────────
            const SizedBox.shrink(),

            // ── Hex ───────────────────────────────────────────────────────
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: const ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: EdgeInsets.zero,
                    title: Text('Hex',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    children: [
                      Text(' txData', style: TextStyle(fontSize: 16)),
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

// ← context passed explicitly — no more dangling _snCtx global
Widget _snHeader(String title, BuildContext context, Function()? onReject) =>
    Container(
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
              if (Navigator.canPop(context)) onReject?.call();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );

Widget _snIcon(String url) => SizedBox(
      height: 50,
      width: 50,
      child: CachedNetworkImage(
        imageUrl: ipfsTohttp(url),
        placeholder: (_, __) =>
            const SizedBox(width: 20, height: 20, child: Loader()),
        errorWidget: (_, __, ___) => const Icon(Icons.error, color: Colors.red),
      ),
    );

Row _snButtons(
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
