import 'dart:async';
import 'package:cryptowallet/components/portfolio.dart';
import 'package:cryptowallet/components/user_balance.dart';
import 'package:cryptowallet/components/user_details_placeholder.dart';
import 'package:cryptowallet/screens/select_blockchain.dart';
import 'package:cryptowallet/screens/add_custom_token.dart';
import 'package:cryptowallet/screens/token.dart';
import 'package:cryptowallet/utils/rpc_urls.dart';
// import 'package:cryptowallet/utils/wallet_connect_v1/wc_connector_v1.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:upgrader/upgrader.dart';
import '../api/notification_api.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../service/crypto_transaction.dart';
import '../service/wallet_connect_service.dart';
import '../service/wallet_service.dart';
import '../utils/get_blockchain_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

// import '../utils/wallet_connect_v2/wc_connector_v2.dart';

class WalletMainBody extends StatefulWidget {
  const WalletMainBody({Key? key}) : super(key: key);

  @override
  _WalletMainBodyState createState() => _WalletMainBodyState();
}

Future<void> handleAllIntent(String? value, BuildContext context) async {
  if (value == null) return;
  bool isWalletConnect = value.trim().startsWith('wc:');

  if (isWalletConnect) {
    await WCService.qrScanHandler(value);
  }
}

class _WalletMainBodyState extends State<WalletMainBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late StreamSubscription _intentDataStreamSubscription;
  late StreamSubscription<dynamic> _streamSubscription;
  List<ValueNotifier<double?>> cryptoNotifiers = [];

  List<Widget> blockChainsArray = <Widget>[];
  List<Timer> cryptoBalancesTimer = <Timer>[];

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    for (Timer cryptoTimer in cryptoBalancesTimer) {
      cryptoTimer.cancel();
    }
    for (ValueNotifier cryptoNotifier in cryptoNotifiers) {
      cryptoNotifier.dispose();
    }
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    initializeBlockchains();
    _streamSubscription =
        EventBusService.instance.on<CryptoNotificationEvent>().listen(
      (event) async {
        await NotificationApi.showNotification(
          title: event.title,
          body: event.body,
        );
      },
    );
    // WcConnectorV1();
    // WcConnectorV2();

    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) async {
      await handleAllIntent(value, context);
    }, onError: (err) {
      if (kDebugMode) {
        print("getLinkStream error: $err");
      }
    });

    ReceiveSharingIntent.getInitialText().then((String? value) async {
      await handleAllIntent(value, context);
    }).catchError((err) {
      if (kDebugMode) {
        print("getLinkStream error: $err");
      }
    });
  }

  void initializeBlockchains() {
    blockChainsArray = <Widget>[];

    for (int i = 0; i < getAllBlockchains.length; i++) {
      final coin = getAllBlockchains[i];
      if (WalletService.removeCoin(coin)) continue;

      final notifier = ValueNotifier<double?>(null);

      cryptoNotifiers.add(notifier);

      blockChainsArray.addAll(
        [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => Token(coin: coin),
                ),
              );
            },
            child: GetBlockChainWidget(
              coin_: coin,
              cryptoAmount_: ValueListenableBuilder<double?>(
                valueListenable: notifier,
                builder: ((_, double? value, Widget? __) {
                  if (value == null) {
                    () async {
                      try {
                        notifier.value = await coin.getBalance(
                          notifier.value == null,
                        );
                      } catch (_) {}

                      cryptoBalancesTimer.add(
                        Timer.periodic(httpPollingDelay, (timer) async {
                          try {
                            notifier.value = await coin.getBalance(
                              notifier.value == null,
                            );
                          } catch (_) {}
                        }),
                      );
                    }();
                    return Container();
                  }

                  return UserBalance(
                    symbol: coin.getSymbol(),
                    haveValue: coin.isRpcWorking,
                    balance: value,
                  );
                }),
              ),
            ),
          ),
        ],
      );

      blockChainsArray.add(const SizedBox(height: 20));
    }
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    super.build(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {});
        },
        child: UpgradeAlert(
          upgrader: Upgrader(
            dialogStyle: UpgradeDialogStyle.cupertino,
            showReleaseNotes: false,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            UserDetailsPlaceHolder(
                              size: .5,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Portfolio(),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: InkWell(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  localization.searchCoin,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      Coin? coin = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const SelectBlockchain(),
                        ),
                      );

                      if (coin == null) return;

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => Token(coin: coin),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localization.assets,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (WalletService.isPharseKey())
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const AddCustomToken(),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      localization.addToken,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.add,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...blockChainsArray,
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
