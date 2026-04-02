// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:math';

import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/components/testnet_banner.dart';
import 'package:wallet_app/components/user_balance.dart';
import 'package:wallet_app/crypto_charts/crypto_chart.dart';
import 'package:wallet_app/extensions/first_or_null.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/interface/ft_explorer.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/providers/token_provider.dart';
import 'package:wallet_app/screens/dms_beneficiary_screen.dart';
import 'package:wallet_app/screens/need_deploy_widget.dart';
import 'package:wallet_app/screens/receive_token.dart';
import 'package:wallet_app/screens/send_form.dart';
import 'package:wallet_app/screens/token_approvals_screen.dart';
import 'package:wallet_app/screens/token_contract_info.dart';
import 'package:wallet_app/service/contact_service.dart';
import 'package:wallet_app/service/transaction_export_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/format_money.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/wallet_transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:intl/intl.dart';

import '../service/wallet_service.dart';
import '../utils/get_token_image.dart';
import 'launch_url.dart';

// ── Provider typedefs ─────────────────────────────────────────────────────────

typedef _InfoProvider
    = AutoDisposeStateNotifierProvider<BlockchainInfoData, BlockchainInfo?>;
typedef _BalanceProvider
    = AutoDisposeStateNotifierProvider<TokenBalance, double?>;
typedef _TxProvider
    = AutoDisposeStateNotifierProvider<TransactionData, TransactionState?>;
typedef _ServiceProvider = AutoDisposeFutureProvider;

// ── Root widget ───────────────────────────────────────────────────────────────

class Token extends StatefulWidget {
  final Coin coin;
  const Token({required this.coin, super.key});

  @override
  _TokenState createState() => _TokenState();
}

class _TokenState extends State<Token> {
  final ValueNotifier<bool> _trxOpen = ValueNotifier(true);
  String _currentAddress = '';
  String? _description;
  late Coin _coin;

  late _InfoProvider _infoController;
  late _TxProvider _transactionsController;
  late _BalanceProvider _tokenBalanceController;
  late _ServiceProvider _infoService;
  late _ServiceProvider _transactionService;
  late _ServiceProvider _tokenBalanceService;

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
    final address = await _coin.getAddress();
    if (mounted) setState(() => _currentAddress = address);
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
        child: Column(
          children: [
            const TestnetBanner(),
            Expanded(
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {},
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      // Approvals button — only for coins that support it
      if (_coin.getApprovals() != null)
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TokenApprovalsScreen(coin: _coin),
            ),
          ),
          icon: const Icon(Icons.security, color: Colors.white),
          tooltip: 'Token Approvals',
        ),

      // Dead Man's Switch — beneficiary view, ETH wallets only
      if (_coin is EthereumCoin)
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DmsBeneficiaryScreen(coin: _coin as EthereumCoin),
            ),
          ),
          icon: const Icon(Icons.shield_outlined, color: Colors.white),
          tooltip: 'Dead Man\'s Switch',
        ),

      // Debug test page — debug mode only
      if (kDebugMode && _coin.haveTestAppproval)
        IconButton(
          icon: const Icon(Icons.bug_report, color: Colors.amber),
          tooltip: 'Test Approvals (debug)',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _ApprovalTestPage(coin: _coin),
            ),
          ),
        ),

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

// ── Coin info card ────────────────────────────────────────────────────────────

class _CoinCard extends ConsumerWidget {
  final Coin coin;
  final String description;
  final _InfoProvider infoController;
  final _ServiceProvider infoService;
  final _BalanceProvider tokenBalanceController;
  final _ServiceProvider tokenBalanceService;
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
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(description,
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  _PriceChangeWidget(
                    infoController: infoController,
                    infoService: infoService,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GetTokenImage(radius: 25, currCoin: coin),
              const SizedBox(height: 10),
              _BalanceWithFiat(
                coin: coin,
                infoController: infoController,
                infoService: infoService,
                tokenBalanceController: tokenBalanceController,
                tokenBalanceService: tokenBalanceService,
                onTransferBlocked: onTransferBlocked,
              ),
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

// ── Balance + fiat value ──────────────────────────────────────────────────────

class _BalanceWithFiat extends ConsumerWidget {
  final Coin coin;
  final _InfoProvider infoController;
  final _ServiceProvider infoService;
  final _BalanceProvider tokenBalanceController;
  final _ServiceProvider tokenBalanceService;
  final VoidCallback onTransferBlocked;

  const _BalanceWithFiat({
    required this.coin,
    required this.infoController,
    required this.infoService,
    required this.tokenBalanceController,
    required this.tokenBalanceService,
    required this.onTransferBlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(tokenBalanceController);
    final info = ref.watch(infoController);
    ref.watch(tokenBalanceService);
    ref.watch(infoService);

    const boldLarge = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

    if (balance == null) {
      return const Text('', style: boldLarge);
    }

    final fiatText = (info != null && info.price > 0 && balance > 0)
        ? info.fiatValue(balance)
        : null;

    return Column(
      children: [
        UserBalance(
          iconSize: 20,
          mustIcon: _LockIcon(coin: coin, onBlocked: onTransferBlocked),
          haveValue: coin.isRpcWorking,
          textStyle: boldLarge,
          balance: balance,
          symbol: coin.tokenAddress() != null
              ? ellipsify(str: coin.getSymbol())
              : coin.getSymbol(),
        ),
        if (fiatText != null) ...[
          const SizedBox(height: 4),
          UserBalance(
            iconSize: 15,
            mustIcon: _LockIcon(coin: coin, onBlocked: onTransferBlocked),
            haveValue: coin.isRpcWorking,
            textStyle: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
            balance: balance * (info?.price ?? 1),
            symbol: info?.currencySymbol ?? "",
            reversed: true,
            iconDivider: const SizedBox(),
          ),
        ],
      ],
    );
  }
}

// ── Price/change widget ───────────────────────────────────────────────────────

class _PriceChangeWidget extends ConsumerWidget {
  final _InfoProvider infoController;
  final _ServiceProvider infoService;

  const _PriceChangeWidget({
    required this.infoController,
    required this.infoService,
  });

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

// ── Action buttons ────────────────────────────────────────────────────────────

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
                MaterialPageRoute(builder: (_) => SendForm(tokenData: coin)),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReceiveToken(coin: coin)),
              );
            }
          },
        ),
        if (coin.getNFTPage() != null) ...[
          const SizedBox(width: 30),
          _ActionButton(
            icon: Icons.image,
            label: 'NFTs',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => coin.getNFTPage()!),
            ),
          ),
        ],
        if (coin.getStakingPage() != null) ...[
          const SizedBox(width: 30),
          _ActionButton(
            icon: FontAwesomeIcons.coins,
            label: 'Stake',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => coin.getStakingPage()!),
            ),
          ),
        ],
        if (coin.getGoalPage() != null) ...[
          const SizedBox(width: 30),
          _ActionButton(
            icon: FontAwesomeIcons.lock,
            label: 'Save',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => coin.getGoalPage()!),
            ),
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

// ── Transaction section ───────────────────────────────────────────────────────

class _TransactionSection extends ConsumerWidget {
  final _TxProvider transactionsController;
  final _ServiceProvider transactionService;
  final Coin coin;
  final ValueNotifier<bool> trxOpen;

  const _TransactionSection({
    required this.transactionsController,
    required this.transactionService,
    required this.coin,
    required this.trxOpen,
  });

  void _showExport(BuildContext context, TransactionState? state) {
    if (state == null || state.transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    final walletTxs = state.transactions
        .map((tx) {
          final isSent =
              tx.from.toLowerCase() == state.currentUser.toLowerCase();
          final isReceived =
              tx.to.toLowerCase() == state.currentUser.toLowerCase();
          if (!isSent && !isReceived) return null;
          final date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(tx.time);
          return WalletTransaction(
            hash: tx.transactionHash,
            from: tx.from,
            to: tx.to,
            amount: tx.tokenAmount.toString(),
            symbol: coin.getSymbol(),
            decimals: tx.decimal,
            timestamp: date,
            status: WalletTxStatus.confirmed,
            direction:
                isSent ? WalletTxDirection.sent : WalletTxDirection.received,
            explorerUrl: coin.getExplorer().replaceFirst(
                  blockExplorerPlaceholder,
                  tx.transactionHash,
                ),
            memo: tx.memo,
          );
        })
        .nonNulls
        .toList();

    TransactionExportSheet.show(
      context: context,
      transactions: walletTxs,
      tokenSymbol: coin.getSymbol(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsController);
    ref.watch(transactionService);

    return ValueListenableBuilder<bool>(
      valueListenable: trxOpen,
      builder: (_, isOpen, __) {
        final items = _buildTransactionItems(state);

        return Column(
          children: [
            _TransactionHeader(
              isOpen: isOpen,
              onTap: () => trxOpen.value = !trxOpen.value,
              onExport: () => _showExport(context, state),
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

  List<Widget> _buildTransactionItems(TransactionState? state) {
    if (state == null) return [];

    final items = <Widget>[];
    int count = 0;

    for (final tx in state.transactions) {
      if (count >= maximumTransactionToSave) break;
      final isSent = tx.from.toLowerCase() == state.currentUser.toLowerCase();
      final isReceived = tx.to.toLowerCase() == state.currentUser.toLowerCase();
      if (!isSent && !isReceived) continue;
      items.addAll([
        _TransactionItem(
          tx: tx,
          coin: coin,
          isSent: isSent,
        ),
        const Divider()
      ]);
      count++;
    }

    return items;
  }
}

class _TransactionHeader extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onTap;
  final VoidCallback? onExport;

  const _TransactionHeader({
    required this.isOpen,
    required this.onTap,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Transactions', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 5),
              Transform.rotate(
                angle: isOpen ? 90 * pi / 180 : 270 * pi / 180,
                child: const Icon(Icons.arrow_back_ios_new, size: 15),
              ),
              const Spacer(),
              if (onExport != null)
                IconButton(
                  onPressed: () {
                    if (pref.get(hideBalanceKey, defaultValue: false)) {
                      return;
                    } else if (onExport != null) {
                      onExport!();
                    }
                  },
                  icon: const Icon(Icons.download, size: 20),
                  tooltip: 'Export',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TokenTransaction tx;
  final Coin coin;
  final bool isSent;

  const _TransactionItem({
    required this.tx,
    required this.coin,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    final trnDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(tx.time);
    final counterparty = isSent ? tx.to : tx.from;
    final contact = ContactService.getContactsForCoin(coin).firstWhereOrNull(
      (c) => c.address.toLowerCase() == counterparty.toLowerCase(),
    );

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
                      coin.getIdenticon(isSent ? tx.to : tx.from, size: 36),
                      const SizedBox(width: 8),
                      Transform.rotate(
                        angle: isSent ? 0 : pi,
                        child: SvgPicture.asset('assets/sent-trans.svg'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserBalance(
                              balance: tx.tokenAmount,
                              symbol: isSent ? '-' : '+',
                              reversed: true,
                              textStyle: TextStyle(
                                fontSize: 18,
                                color: isSent ? Colors.red : Colors.green,
                              ),
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
                            Text(
                              isSent ? 'Sent' : 'Received',
                              style: TextStyle(
                                color: isSent ? Colors.red : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              contact != null
                                  ? ellipsify(str: contact.name)
                                  : ellipsify(str: counterparty),
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: contact != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
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

// ── Debug: Approval test page ─────────────────────────────────────────────────

class _ApprovalTestPage extends StatefulWidget {
  final Coin coin;
  const _ApprovalTestPage({required this.coin});

  @override
  State<_ApprovalTestPage> createState() => _ApprovalTestPageState();
}

class _ApprovalTestPageState extends State<_ApprovalTestPage> {
  bool _loading = false;
  String? _result;
  bool _isError = false;
  String? _explorerUrl;

  Future<void> _createApproval() async {
    setState(() {
      _loading = true;
      _result = null;
      _explorerUrl = null;
      _isError = false;
    });

    try {
      final txHash = await widget.coin.testCreateApproval();

      if (txHash == null) {
        setState(() {
          _result = 'No result returned';
          _isError = true;
        });
        return;
      }

      final isError = txHash.startsWith('Error') ||
          txHash.startsWith('Failed') ||
          txHash.startsWith('No ');

      setState(() {
        _result = txHash;
        _isError = isError;
        if (!isError) {
          _explorerUrl = widget.coin.formatTxHash(txHash);
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.coin.getSymbol()} — Approval Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Banner(
              color: Colors.red,
              icon: Icons.warning_amber_rounded,
              message: 'Debug only — creates a real on-chain approval.\n'
                  'Use testnet only.',
            ),
            const SizedBox(height: 20),
            _InfoCard(coin: widget.coin),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _createApproval,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(_loading ? 'Creating...' : 'Create Test Approval'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TokenApprovalsScreen(coin: widget.coin),
                  ),
                ),
                icon: const Icon(Icons.security),
                label: const Text('View Approvals'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _ResultCard(
                result: _result!,
                isError: _isError,
                explorerUrl: _explorerUrl,
                coin: widget.coin,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Coin coin;
  const _InfoCard({required this.coin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COIN INFO',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          _InfoRow('Name', coin.getName()),
          _InfoRow('Symbol', coin.getSymbol()),
          _InfoRow('Approvals supported',
              coin.getApprovals() != null ? 'Yes' : 'No'),
          _InfoRow('Test approval',
              coin.haveTestAppproval ? 'Available' : 'Not available'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label:  ',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ── Result card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final String result;
  final bool isError;
  final String? explorerUrl;
  final Coin coin;

  const _ResultCard({
    required this.result,
    required this.isError,
    required this.explorerUrl,
    required this.coin,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : Colors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                isError ? 'Failed' : 'Approval created!',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: color, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            result,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          if (!isError) ...[
            const SizedBox(height: 12),
            Text(
              '1. Tap "View Approvals" to see it\n'
              '2. Wait ~15s for chain confirmation first',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            if (explorerUrl != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  await launchPageUrl(
                    context: context,
                    url: explorerUrl!,
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.open_in_new, size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'View on explorer',
                      style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Reusable banner ───────────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;

  const _Banner({
    required this.color,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
