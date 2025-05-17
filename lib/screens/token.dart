import 'dart:async';
import 'dart:math';
import 'package:wallet_app/components/user_balance.dart';
import 'package:wallet_app/crypto_charts/crypto_chart.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/interface/ft_explorer.dart';
import 'package:wallet_app/providers/token_provider.dart';
import 'package:wallet_app/screens/need_deploy_widget.dart';
import 'package:wallet_app/screens/receive_token.dart';
import 'package:wallet_app/screens/send_token.dart';
import 'package:wallet_app/screens/token_contract_info.dart';
import 'package:wallet_app/screens/unstake_token.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/format_money.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:intl/intl.dart';

import '../service/wallet_service.dart';
import '../utils/get_token_image.dart';
import 'launch_url.dart';

class Token extends StatefulWidget {
  final Coin coin;
  const Token({required this.coin, Key? key}) : super(key: key);

  @override
  _TokenState createState() => _TokenState();
}

class _TokenState extends State<Token> {
  late Map tokenTransaction;
  bool skipNetworkRequest = true;
  ValueNotifier<bool> trxOpen = ValueNotifier(true);
  late String currentAddress;
  String? description;
  late Coin coin;
  late AutoDisposeStateNotifierProvider<BlockchainInfoData, BlockchainInfo?>
      infoController;
  late AutoDisposeStateNotifierProvider<TransactionData, Map?>
      transactionsController;
  late AutoDisposeStateNotifierProvider<TokenBalance, double?>
      tokenBalanceController;
  late AutoDisposeFutureProvider infoService;
  late AutoDisposeFutureProvider transactionService;
  late AutoDisposeFutureProvider tokenBalanceService;
  @override
  void initState() {
    super.initState();
    coin = widget.coin;
    setAddress();
    infoController =
        StateNotifierProvider.autoDispose<BlockchainInfoData, BlockchainInfo?>(
            (ref) => BlockchainInfoData(coin: coin));
    infoService = FutureProvider.autoDispose((ref) {
      ref.read(infoController.notifier).getBlockchainPrice();
      final timer = Timer.periodic(
        httpPollingDelay,
        (Timer t) => ref.invalidateSelf(),
      );
      ref.onDispose(timer.cancel);
      return null;
    });
    transactionsController =
        StateNotifierProvider.autoDispose<TransactionData, Map?>(
            (ref) => TransactionData(coin: coin));

    transactionService = FutureProvider.autoDispose((ref) {
      ref.read(transactionsController.notifier).getTokenTransactions();
      final timer = Timer.periodic(
        httpPollingDelay,
        (Timer t) => ref.invalidateSelf(),
      );
      ref.onDispose(timer.cancel);
      return null;
    });
    tokenBalanceController =
        StateNotifierProvider.autoDispose<TokenBalance, double?>(
            (ref) => TokenBalance(coin: coin));
    tokenBalanceService = FutureProvider.autoDispose((ref) {
      ref.read(tokenBalanceController.notifier).getBlockchainBalance();
      final timer = Timer.periodic(
        httpPollingDelay,
        (Timer t) => ref.invalidateSelf(),
      );
      ref.onDispose(timer.cancel);
      return null;
    });

    if (coin is FTExplorer) {
      description = coin.getDefault();
    }
  }

  Future setAddress() async {
    currentAddress = await coin.getAddress();
  }

  void _snackBarTransferBlocked() {
    final snack = ScaffoldMessenger.of(context);
    snack.clearSnackBars();
    const style = TextStyle(color: Colors.white);
    final snackbar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        localization.withdrawalBlockedByOwnerPermission,
        style: style,
      ),
      action: SnackBarAction(
        label: 'View',
        textColor: Colors.white,
        onPressed: () async {},
      ),
    );
    snack.showSnackBar(snackbar);
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    description = description ?? localization.coin;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          coin.tokenAddress() != null
              ? ellipsify(str: coin.getName())
              : coin.getName(),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => CryptoChart(
                    coin: coin,
                  ),
                ),
              );
            },
            icon: SvgPicture.asset(
              'assets/chart-mixed.svg',
              color: Colors.white,
            ),
          ),
          if (!enableTestNet)
            if (coin.getRampID().isNotEmpty)
              IconButton(
                onPressed: () async {
                  final url = getRampLink(
                    coin.getRampID(),
                    currentAddress.toLowerCase(),
                  );
                  await launchPageUrl(
                    context: context,
                    url: url,
                  );
                },
                icon: const Icon(
                  FontAwesomeIcons.creditCard,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          if (coin.tokenAddress() != null)
            IconButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TokenContractInfo(
                      coin: coin,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.info,
                color: Colors.white,
              ),
            ),
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {},
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        description!,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                      Consumer(
                                        builder: (
                                          BuildContext context,
                                          WidgetRef ref,
                                          Widget? child,
                                        ) {
                                          ref.watch(infoService);
                                          final crypto =
                                              ref.watch(infoController);

                                          return crypto != null
                                              ? Row(
                                                  children: [
                                                    Text(
                                                      crypto.pricewithSym,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      crypto.changeSign +
                                                          formatMoney(
                                                            crypto.change,
                                                            true,
                                                          ) +
                                                          '%',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: crypto.color,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : const Text(
                                                  '',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                );
                                        },
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  GetTokenImage(
                                    radius: 25,
                                    currCoin: coin,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Consumer(builder: (
                                    BuildContext context,
                                    WidgetRef ref,
                                    Widget? child,
                                  ) {
                                    final tokenBalance =
                                        ref.watch(tokenBalanceController);
                                    ref.watch(tokenBalanceService);

                                    if (tokenBalance != null) {
                                      return UserBalance(
                                        iconSize: 20,
                                        mustIcon: FutureBuilder<bool>(
                                          future: coin.canTransfer,
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return Container();
                                            }
                                            if (snapshot.data!) {
                                              return Container();
                                            }
                                            return InkWell(
                                              child: const Icon(Icons.lock),
                                              onTap: () {
                                                if (mounted) {
                                                  _snackBarTransferBlocked();
                                                }
                                              },
                                            );
                                          },
                                        ),
                                        haveValue: coin.isRpcWorking,
                                        textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        balance: tokenBalance,
                                        symbol: coin.tokenAddress() != null
                                            ? ellipsify(str: coin.getSymbol())
                                            : coin.getSymbol(),
                                      );
                                    } else {
                                      return const Text(
                                        '',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  }),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: WalletService.isViewKey()
                                                ? null
                                                : () async {
                                                    bool canTr =
                                                        await coin.canTransfer;
                                                    if (!canTr) {
                                                      _snackBarTransferBlocked();
                                                      return;
                                                    }
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            SendToken(
                                                          tokenData: coin,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: appBackgroundblue
                                                    .withOpacity(WalletService
                                                            .isViewKey()
                                                        ? 0.3
                                                        : 1),
                                              ),
                                              child: Icon(
                                                Icons.arrow_upward,
                                                color: Colors.black.withOpacity(
                                                    WalletService.isViewKey()
                                                        ? 0.3
                                                        : 1),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(localization.send),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              bool canTr =
                                                  await coin.canTransfer;
                                              if (!canTr) {
                                                _snackBarTransferBlocked();
                                                return;
                                              }
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      ReceiveToken(
                                                    coin: coin,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: appBackgroundblue,
                                              ),
                                              child: const Icon(
                                                  Icons.arrow_downward,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(localization.receive),
                                        ],
                                      ),
                                      if (coin.getNFTPage() != null) ...[
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        coin.getNFTPage()!,
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: appBackgroundblue,
                                                ),
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const Text('NFTs'),
                                          ],
                                        ),
                                      ],
                                      if (coin.getStakingPage() != null) ...[
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        coin.getStakingPage()!,
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: appBackgroundblue,
                                                ),
                                                child: const Icon(
                                                  FontAwesomeIcons.coins,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const Text('Stake'),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        UnStakeToken(
                                                            tokenData: coin),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: appBackgroundblue,
                                                ),
                                                child: const Icon(
                                                  FontAwesomeIcons.piggyBank,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const Text('Unstake'),
                                          ],
                                        ),
                                      ],
                                      if (coin.getGoalPage() != null) ...[
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        coin.getGoalPage()!,
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: appBackgroundblue,
                                                ),
                                                child: const Icon(
                                                  FontAwesomeIcons.lock,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const Text('Save'),
                                          ],
                                        ),
                                      ]
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        NeedDeploymentWidget(coin: coin),
                        const SizedBox(
                          height: 20,
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final tokenTransaction =
                                ref.watch(transactionsController);

                            ref.watch(transactionService);
                            return ValueListenableBuilder<bool>(
                                valueListenable: trxOpen,
                                builder: (_, isOpen, __) {
                                  final listTransactions = <Widget>[];
                                  if (tokenTransaction != null) {
                                    List data = tokenTransaction['trx'] as List;

                                    int count = 1;

                                    for (final datum in data) {
                                      if (datum == null) continue;
                                      if (count > maximumTransactionToSave) {
                                        break;
                                      }
                                      if (datum['from']
                                              .toString()
                                              .toLowerCase() !=
                                          tokenTransaction['currentUser']
                                              .toString()
                                              .toLowerCase()) continue;
                                      final tokenSent = datum['value'] /
                                          pow(10, datum['decimal']);
                                      DateTime trnDate =
                                          DateFormat("yyyy-MM-dd hh:mm:ss")
                                              .parse(datum['time']);

                                      listTransactions.addAll([
                                        GestureDetector(
                                          onTap: () async {
                                            final url = widget.coin
                                                .getExplorer()
                                                .replaceFirst(
                                                  blockExplorerPlaceholder,
                                                  datum['transactionHash'],
                                                );
                                            await launchPageUrl(
                                              context: context,
                                              url: url,
                                            );
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Row(
                                                        children: [
                                                          SvgPicture.asset(
                                                              'assets/sent-trans.svg'),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                UserBalance(
                                                                  balance:
                                                                      tokenSent,
                                                                  symbol: '-',
                                                                  reversed:
                                                                      true,
                                                                  textStyle:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Text(
                                                                  '${trnDate.day} ${months[trnDate.month - 1]} ${trnDate.year}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                const Text(
                                                                    'Sent'),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Text(
                                                                  ellipsify(
                                                                    str: datum[
                                                                        'to'],
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Divider()
                                      ]);
                                      count++;
                                    }
                                  }
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          trxOpen.value = !trxOpen.value;
                                        },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  "Transactions",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Transform.rotate(
                                                  child: const Icon(
                                                    Icons.arrow_back_ios_new,
                                                    size: 15,
                                                  ),
                                                  angle: isOpen
                                                      ? 90 * pi / 180
                                                      : 270 * pi / 180,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (listTransactions.isNotEmpty && isOpen)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: listTransactions,
                                        ),
                                    ],
                                  );
                                });
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
