// ignore_for_file: library_private_types_in_public_api

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
  const Token({required this.coin, super.key});

  @override
  _TokenState createState() => _TokenState();
}

class _TokenState extends State<Token> {
  final ValueNotifier<bool> _trxOpen = ValueNotifier(true);
  late String _currentAddress;
  String? _description;
  late Coin _coin;

  late AutoDisposeStateNotifierProvider<BlockchainInfoData, BlockchainInfo?>
      _infoController;
  late AutoDisposeStateNotifierProvider<TransactionData, TransactionState?>
      _transactionsController;
  late AutoDisposeStateNotifierProvider<TokenBalance, double?>
      _tokenBalanceController;
  late AutoDisposeFutureProvider _infoService;
  late AutoDisposeFutureProvider _transactionService;
  late AutoDisposeFutureProvider _tokenBalanceService;

  @override
  void initState() {
    super.initState();
    _coin = widget.coin;
    _setAddress();

    _infoController = StateNotifierProvider.autoDispose(
        (ref) => BlockchainInfoData(coin: _coin));
    _infoService = FutureProvider.autoDispose((ref) {
      ref.read(_infoController.notifier).getBlockchainPrice();
      final t = Timer.periodic(httpPollingDelay, (_) => ref.invalidateSelf());
      ref.onDispose(t.cancel);
      return null;
    });

    _transactionsController = StateNotifierProvider.autoDispose(
        (ref) => TransactionData(coin: _coin));
    _transactionService = FutureProvider.autoDispose((ref) {
      ref.read(_transactionsController.notifier).getTokenTransactions();
      final t = Timer.periodic(httpPollingDelay, (_) => ref.invalidateSelf());
      ref.onDispose(t.cancel);
      return null;
    });

    _tokenBalanceController =
        StateNotifierProvider.autoDispose((ref) => TokenBalance(coin: _coin));
    _tokenBalanceService = FutureProvider.autoDispose((ref) {
      ref.read(_tokenBalanceController.notifier).getBlockchainBalance();
      final t = Timer.periodic(httpPollingDelay, (_) => ref.invalidateSelf());
      ref.onDispose(t.cancel);
      return null;
    });

    if (_coin is FTExplorer) _description = _coin.getDefault();
  }

  Future<void> _setAddress() async {
    _currentAddress = await _coin.getAddress();
  }

  void _showTransferBlockedSnackbar() {
    final snack = ScaffoldMessenger.of(context);
    snack.clearSnackBars();
    snack.showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        localization.withdrawalBlockedByOwnerPermission,
        style: const TextStyle(color: Colors.white),
      ),
      action: SnackBarAction(
        label: 'View',
        textColor: Colors.white,
        onPressed: () {},
      ),
    ));
  }

  late AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    _description ??= localization.coin;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _coin.tokenAddress() != null
              ? ellipsify(str: _coin.getName())
              : _coin.getName(),
        ),
        actions: _buildAppBarActions(context),
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
                        _CoinCard(
                          coin: _coin,
                          description: _description!,
                          infoController: _infoController,
                          infoService: _infoService,
                          tokenBalanceController: _tokenBalanceController,
                          tokenBalanceService: _tokenBalanceService,
                          onTransferBlocked: _showTransferBlockedSnackbar,
                          currentAddress: _currentAddress,
                          localization: localization,
                        ),
                        NeedDeploymentWidget(coin: _coin),
                        const SizedBox(height: 20),
                        _TransactionSection(
                          transactionsController: _transactionsController,
                          transactionService: _transactionService,
                          coin: _coin,
                          trxOpen: _trxOpen,
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

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CryptoChart(coin: _coin)),
        ),
        icon: SvgPicture.asset('assets/chart-mixed.svg', color: Colors.white),
      ),
      if (!enableTestNet && _coin.getRampID().isNotEmpty)
        IconButton(
          onPressed: () async {
            final url =
                getRampLink(_coin.getRampID(), _currentAddress.toLowerCase());
            await launchPageUrl(context: context, url: url);
          },
          icon: const Icon(FontAwesomeIcons.creditCard,
              color: Colors.white, size: 20),
        ),
      if (_coin.tokenAddress() != null)
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TokenContractInfo(coin: _coin)),
          ),
          icon: const Icon(Icons.info, color: Colors.white),
        ),
    ];
  }
}

// ── Coin info card ─────────────────────────────────────────────────────────────

class _CoinCard extends ConsumerWidget {
  final Coin coin;
  final String description;
  final AutoDisposeStateNotifierProvider<BlockchainInfoData, BlockchainInfo?>
      infoController;
  final AutoDisposeFutureProvider infoService;
  final AutoDisposeStateNotifierProvider<TokenBalance, double?>
      tokenBalanceController;
  final AutoDisposeFutureProvider tokenBalanceService;
  final VoidCallback onTransferBlocked;
  final String currentAddress;
  final AppLocalizations localization;

  const _CoinCard({
    required this.coin,
    required this.description,
    required this.infoController,
    required this.infoService,
    required this.tokenBalanceController,
    required this.tokenBalanceService,
    required this.onTransferBlocked,
    required this.currentAddress,
    required this.localization,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Column(
            children: [
              // Price row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(description,
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  _PriceChangeConsumer(
                    infoController: infoController,
                    infoService: infoService,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GetTokenImage(radius: 25, currCoin: coin),
              const SizedBox(height: 10),
              // Balance
              Consumer(builder: (context, ref, _) {
                final balance = ref.watch(tokenBalanceController);
                ref.watch(tokenBalanceService);
                if (balance == null) {
                  return const Text('',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                }
                return UserBalance(
                  iconSize: 20,
                  mustIcon: _LockIcon(coin: coin, onBlocked: onTransferBlocked),
                  haveValue: coin.isRpcWorking,
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  balance: balance,
                  symbol: coin.tokenAddress() != null
                      ? ellipsify(str: coin.getSymbol())
                      : coin.getSymbol(),
                );
              }),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              _ActionButtons(
                coin: coin,
                onTransferBlocked: onTransferBlocked,
                localization: localization,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Price/change consumer ─────────────────────────────────────────────────────

class _PriceChangeConsumer extends ConsumerWidget {
  final AutoDisposeStateNotifierProvider<BlockchainInfoData, BlockchainInfo?>
      infoController;
  final AutoDisposeFutureProvider infoService;

  const _PriceChangeConsumer(
      {required this.infoController, required this.infoService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(infoService);
    final info = ref.watch(infoController);
    if (info == null) return const Text('', style: TextStyle(fontSize: 18));
    return Row(
      children: [
        Text(info.pricewithSym,
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(width: 5),
        Text(
          '${info.changeSign}${formatMoney(info.change, true)}%',
          style: TextStyle(fontSize: 14, color: info.color),
        ),
      ],
    );
  }
}

// ── Lock icon ─────────────────────────────────────────────────────────────────

class _LockIcon extends StatelessWidget {
  final Coin coin;
  final VoidCallback onBlocked;

  const _LockIcon({required this.coin, required this.onBlocked});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: coin.canTransfer,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!) return const SizedBox();
        return InkWell(
          onTap: onBlocked,
          child: const Icon(Icons.lock),
        );
      },
    );
  }
}

// ── Action buttons ─────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final Coin coin;
  final VoidCallback onTransferBlocked;
  final AppLocalizations localization;

  const _ActionButtons({
    required this.coin,
    required this.onTransferBlocked,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.arrow_upward,
          label: localization.send,
          disabled: WalletService.isViewKey(),
          onTap: () async {
            if (!await coin.canTransfer) {
              onTransferBlocked();
              return;
            }
            if (context.mounted) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SendToken(tokenData: coin)));
            }
          },
        ),
        const SizedBox(width: 30),
        _ActionButton(
          icon: Icons.arrow_downward,
          label: localization.receive,
          onTap: () async {
            if (!await coin.canTransfer) {
              onTransferBlocked();
              return;
            }
            if (context.mounted) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ReceiveToken(coin: coin)));
            }
          },
        ),
        if (coin.getNFTPage() != null) ...[
          const SizedBox(width: 30),
          _ActionButton(
            icon: Icons.image,
            label: 'NFTs',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => coin.getNFTPage()!)),
          ),
        ],
        if (coin.getStakingPage() != null) ...[
          const SizedBox(width: 30),
          _ActionButton(
            icon: FontAwesomeIcons.coins,
            label: 'Stake',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => coin.getStakingPage()!)),
          ),
        ],
        if (coin.getGoalPage() != null) ...[
          const SizedBox(width: 30),
          _ActionButton(
            icon: FontAwesomeIcons.lock,
            label: 'Save',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => coin.getGoalPage()!)),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: disabled ? null : onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appBackgroundblue.withOpacity(disabled ? 0.3 : 1),
            ),
            child: Icon(
              icon,
              color: Colors.black.withOpacity(disabled ? 0.3 : 1),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}

// ── Transaction section ────────────────────────────────────────────────────────

class _TransactionSection extends ConsumerWidget {
  final AutoDisposeStateNotifierProvider<TransactionData, TransactionState?>
      transactionsController;
  final AutoDisposeFutureProvider transactionService;
  final Coin coin;
  final ValueNotifier<bool> trxOpen;

  const _TransactionSection({
    required this.transactionsController,
    required this.transactionService,
    required this.coin,
    required this.trxOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsController);
    ref.watch(transactionService);

    return ValueListenableBuilder<bool>(
      valueListenable: trxOpen,
      builder: (_, isOpen, __) {
        final items = <Widget>[];

        if (state != null) {
          int count = 0;
          for (final tx in state.transactions) {
            if (count >= maximumTransactionToSave) break;
            if (tx.from.toLowerCase() != state.currentUser.toLowerCase()) {
              continue;
            }

            items.addAll([
              _TransactionItem(tx: tx, coin: coin),
              const Divider(),
            ]);
            count++;
          }
        }

        return Column(
          children: [
            GestureDetector(
              onTap: () => trxOpen.value = !trxOpen.value,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Transactions',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 5),
                      Transform.rotate(
                        angle: isOpen ? 90 * pi / 180 : 270 * pi / 180,
                        child: const Icon(Icons.arrow_back_ios_new, size: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (items.isNotEmpty && isOpen)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              ),
          ],
        );
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TokenTransaction tx;
  final Coin coin;

  const _TransactionItem({required this.tx, required this.coin});

  @override
  Widget build(BuildContext context) {
    final trnDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(tx.time);

    return GestureDetector(
      onTap: () async {
        final url = coin
            .getExplorer()
            .replaceFirst(blockExplorerPlaceholder, tx.transactionHash);
        await launchPageUrl(context: context, url: url);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/sent-trans.svg'),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserBalance(
                              balance: tx.tokenAmount,
                              symbol: '-',
                              reversed: true,
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${trnDate.day} ${months[trnDate.month - 1]} ${trnDate.year}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Sent'),
                            const SizedBox(height: 10),
                            Text(
                              ellipsify(str: tx.to),
                              overflow: TextOverflow.fade,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
