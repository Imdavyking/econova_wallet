// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:wallet_app/components/portfolio.dart';
import 'package:wallet_app/components/testnet_banner.dart';
import 'package:wallet_app/components/wallet/wallet_assets_header.dart';
import 'package:wallet_app/components/wallet/wallet_coin_list.dart';
import 'package:wallet_app/components/wallet/wallet_header.dart';
import 'package:wallet_app/components/wallet/wallet_search_bar.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/wallet_connect_reown/wc_connector_reown.dart';
import 'package:wallet_app/utils/wallet_connect_v1/wc_connector_v1.dart';
import '../api/notification_api.dart';
import '../service/crypto_transaction.dart';
import '../service/wallet_connect_service.dart';
import '../service/wallet_service.dart';
import '../utils/wallet_connect_v2/wc_connector_v2.dart';

class WalletMainBody extends StatefulWidget {
  const WalletMainBody({super.key});

  @override
  _WalletMainBodyState createState() => _WalletMainBodyState();
}

Future<void> handleAllIntent(String? value, BuildContext context) async {
  if (value == null) return;
  if (value.trim().startsWith('wc:')) {
    await WCService.qrScanHandler(value);
  }
}

class _WalletMainBodyState extends State<WalletMainBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late StreamSubscription<dynamic> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        EventBusService.instance.on<CryptoNotificationEvent>().listen(
      (event) async {
        debugPrint('Notification: ${event.title} - ${event.body}');
        await NotificationApi.showNotification(
          title: event.title,
          body: event.body,
        );
      },
    );
    WcConnectorV1();
    WcConnectorV2();
    WCConnectorReown();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Expanded(
          child: SafeArea(
            child: ValueListenableBuilder<List<Coin>>(
              valueListenable: coinListener,
              builder: (_, chains, __) {
                final visibleCoins = chains
                    .where((coin) => !WalletService.removeCoin(coin))
                    .toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    supportedChains = await getChainsSortedByBalance();
                  },
                  child: UpgradeAlert(
                    upgrader: Upgrader(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WalletHeader(),
                          const SizedBox(height: 30),
                          const Portfolio(),
                          const SizedBox(height: 20),
                          const WalletSearchBar(),
                          const WalletAssetsHeader(),
                          WalletCoinList(coins: visibleCoins),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
