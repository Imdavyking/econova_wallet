import 'dart:async';
import '../service/wallet_service.dart';
import 'package:cryptowallet/utils/app_config.dart';
import 'package:cryptowallet/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jazzicon/jazzicon.dart';

import '../main.dart';
import '../utils/blockie_widget.dart';

class ChangeIdenticon extends StatefulWidget {
  const ChangeIdenticon({Key? key}) : super(key: key);

  @override
  _ChangeIdenticonState createState() => _ChangeIdenticonState();
}

class _ChangeIdenticonState extends State<ChangeIdenticon> {
  ValueNotifier<String> ethAddr = ValueNotifier('');
  Future<void> getETHAddr() async {
    try {
      final data = WalletService.getActiveKey(walletImportType)!.data;

      final web3Response = await evmFromSymbol('ETH')!.importData(data);

      ethAddr.value = web3Response.address;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getETHAddr();
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ETH Account identicon",
        ),
      ),
      body: SizedBox(
        height: double.infinity,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Text(
                          localization.identiconMsg,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ValueListenableBuilder<Box<dynamic>>(
                          valueListenable:
                              pref.listenable(keys: [useBlockiesKey]),
                          builder: (context, box, _) {
                            final isBlockie =
                                box.get(useBlockiesKey, defaultValue: true);
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await pref.put(useBlockiesKey, false);
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            color: isBlockie
                                                ? null
                                                : Colors.blueAccent,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(26),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: ValueListenableBuilder<String>(
                                            valueListenable: ethAddr,
                                            builder: (_, ___, __) => Container(
                                              child: Jazzicon.getIconWidget(
                                                Jazzicon.getJazziconData(
                                                  40,
                                                  address: ethAddr.value,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                color: isBlockie
                                                    ? null
                                                    : Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(22),
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(2),
                                            ),
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        "Jazzicons",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 40,
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      await pref.put(useBlockiesKey, true);
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: isBlockie
                                                ? Colors.blueAccent
                                                : null,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(26),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: Container(
                                            child:
                                                ValueListenableBuilder<String>(
                                              valueListenable: ethAddr,
                                              builder: (_, ___, __) =>
                                                  Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: BlockieWidget(
                                                  size: .6,
                                                  data: ethAddr.value,
                                                ),
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              color: isBlockie
                                                  ? Theme.of(context)
                                                      .scaffoldBackgroundColor
                                                  : null,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(22),
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(2),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text(
                                          "Blockies",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        )
                                      ],
                                    )),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
