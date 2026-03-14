import 'dart:convert' hide Encoding;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../coins/ethereum_coin.dart';
import '../components/loader.dart';
import '../utils/app_config.dart';
import '../utils/auth_utils.dart';
import '../utils/json_viewer.dart';
import '../utils/slide_up_panel.dart';

Future<void> addEthereumChain({
  required BuildContext context,
  required String jsonObj,
  required Function onConfirm,
  required Function onReject,
}) async {
  final localization = AppLocalizations.of(context)!;
  final isLoading = ValueNotifier(false);

  await slideUpPanel(
    context,
    Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localization.addNetwork,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          JsonViewer(json.decode(jsonObj)),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (_, loading, __) {
              if (loading) return const Row(children: [Loader()]);
              return Row(children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: appBackgroundblue),
                    onPressed: () async {
                      if (await authenticate(context)) {
                        isLoading.value = true;
                        try {
                          await onConfirm();
                        } catch (_) {}
                        isLoading.value = false;
                      } else {
                        onReject();
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
                    onPressed: () => onReject(),
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
    canDismiss: false,
  );
}

Future<void> switchEthereumChain({
  required BuildContext context,
  required EthereumCoin currentChain,
  required EthereumCoin switchChain,
  required Function onConfirm,
  required Function onReject,
}) async {
  final localization = AppLocalizations.of(context)!;

  await slideUpPanel(
    context,
    Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localization.switchChainRequest,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                backgroundImage: AssetImage(currentChain.getImage()),
              ),
              const Icon(Icons.arrow_right_alt_outlined),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                backgroundImage: AssetImage(switchChain.getImage()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            localization.switchChainIdMessage(
                switchChain.getSymbol(), switchChain.chainId),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: appBackgroundblue),
                onPressed: () => onConfirm(),
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
                onPressed: () => onReject(),
                child: Text(localization.reject,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ]),
        ],
      ),
    ),
    canDismiss: false,
  );
}
