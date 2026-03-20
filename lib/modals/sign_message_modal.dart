import 'dart:convert' hide Encoding;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../components/loader.dart';
import '../utils/app_config.dart';
import '../utils/auth_utils.dart';
import '../utils/json_viewer.dart';
import '../utils/rpc_urls.dart';
import '../utils/slide_up_panel.dart';

Future<void> signMessage({
  required BuildContext context,
  String? data,
  String? networkIcon,
  String? name,
  required Function onConfirm,
  required Function()? onReject,
  required String messageType,
}) async {
  String? decoded = data;
  if (messageType == personalSignKey && data != null && isHexString(data)) {
    try {
      decoded = ascii.decode(txDataToUintList(data));
    } catch (_) {}
  }

  final localization = AppLocalizations.of(context)!;
  final isSigning = ValueNotifier(false);

  slideUpPanel(
    context,
    SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const IconButton(
                      onPressed: null,
                      icon: Icon(Icons.close, color: Colors.transparent)),
                  Text(localization.signMessage,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) onReject!();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            if (networkIcon != null)
              SizedBox(
                height: 50,
                width: 50,
                child: CachedNetworkImage(
                  imageUrl: ipfsTohttp(networkIcon),
                  placeholder: (_, __) => const SizedBox(
                      width: 20,
                      height: 20,
                      child: Loader(color: appPrimaryColor)),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.error, color: Colors.red),
                ),
              ),
            if (name != null) Text(name, style: const TextStyle(fontSize: 16)),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.zero,
                  title: Text(localization.message,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  children: [
                    if (messageType == typedMessageSignKey)
                      Builder(builder: (_) {
                        try {
                          return JsonViewer(json.decode(decoded!),
                              fontSize: 16);
                        } catch (_) {
                          return Text(decoded!,
                              style: const TextStyle(fontSize: 16));
                        }
                      })
                    else
                      Text(decoded!, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isSigning,
              builder: (_, signing, __) {
                if (signing) return const Row(children: [Loader()]);
                return Row(children: [
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
                          onReject!();
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
              },
            ),
          ],
        ),
      ),
    ),
    canDismiss: false,
  );
}
