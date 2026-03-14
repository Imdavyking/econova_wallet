import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../components/loader.dart';
import '../utils/app_config.dart';
import '../utils/slide_up_panel.dart';

Future<void> connectWalletModal({
  required BuildContext context,
  String? url,
  String? authToken,
  required Function onConfirm,
  required Function()? onReject,
}) async {
  if (!context.mounted) return;
  final localization = AppLocalizations.of(context)!;
  final isSigning = ValueNotifier(false);

  await slideUpPanel(
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
                  Text(localization.connectedTo,
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
            if (url != null) ...[
              Text(localization.url,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(url, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
            ],
            if (authToken != null && authToken.trim().isNotEmpty) ...[
              Text(localization.authToken,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(authToken, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
            ],
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
                        isSigning.value = true;
                        try {
                          await onConfirm();
                        } catch (_) {}
                        isSigning.value = false;
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
