import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/components/user_balance.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/screens/token.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';
import 'package:wallet_app/service/dms_background_listener.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/get_blockchain_widget.dart';
import 'package:wallet_app/utils/rpc_urls.dart';

class WalletCoinListItem extends StatefulWidget {
  final Coin coin;
  const WalletCoinListItem({super.key, required this.coin});

  @override
  State<WalletCoinListItem> createState() => _WalletCoinListItemState();
}

class _WalletCoinListItemState extends State<WalletCoinListItem>
    with WidgetsBindingObserver {
  final ValueNotifier<double?> _balanceNotifier = ValueNotifier(null);
  Timer? _timer;
  bool _heartbeatInFlight = false; // ← guard against concurrent heartbeats

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBalance();
    _timer = Timer.periodic(httpPollingDelay, (_) => _loadBalance());
    _startListener();
  }

  Future<void> _startListener() async {
    if (widget.coin is! EthereumCoin) return;
    try {
      final pubKey = await widget.coin.getPublicKey();
      if (pubKey == null) return;
      // Singleton — safe to call multiple times, no-op if already running
      await DmsBackgroundListener.instance.start(pubKey);
    } catch (e) {
      debugPrint('DMS listener start error: $e');
    }
  }

  Future<void> _loadBalance() async {
    try {
      final balance =
          await widget.coin.getBalance(_balanceNotifier.value == null);
      if (mounted) _balanceNotifier.value = balance;
      await _maybeHeartbeat();
    } catch (_) {}
  }

  Future<void> _maybeHeartbeat() async {
    if (_heartbeatInFlight) return;

    if (walletImportType.index != WalletType.secretPhrase.index) return;

    if (DeadManSwitchService.state != DmsState.active) return;
    final remaining = DeadManSwitchService.timeRemaining;
    final cfg = DeadManSwitchService.config;
    if (remaining == null || cfg == null) return;

    // Only heartbeat when 50% of timeout has elapsed
    final halfTimeout = Duration(seconds: cfg.timeoutSeconds ~/ 2);
    debugPrint(
      'DMS heartbeat check — remaining: ${remaining.inSeconds}s, halfTimeout: ${halfTimeout.inSeconds}s',
    );
    if (remaining > halfTimeout) return;

    final mnemonic = WalletService.getActiveKey(walletImportType)?.data;
    if (mnemonic == null) return;
    _heartbeatInFlight = true;
    debugPrint('Heartbeat triggered — remaining time: ${remaining.inSeconds}s');
    // Fire and forget — non-fatal if it fails
    DeadManSwitchService.heartbeat(mnemonic: mnemonic)
        .catchError((_) => DmsErr('Silent heartbeat failed') as DmsResult)
        .whenComplete(() => _heartbeatInFlight = false);
  }

  // Reconnect when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startListener();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _balanceNotifier.dispose();
    // Do NOT stop the listener here — it's a singleton that should
    // outlive this widget. It will keep running across rebuilds.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => Token(coin: widget.coin)),
        );
      },
      child: GetBlockChainWidget(
        coin_: widget.coin,
        cryptoAmount_: ValueListenableBuilder<double?>(
          valueListenable: _balanceNotifier,
          builder: (_, double? value, __) {
            if (value == null) return const SizedBox.shrink();
            return UserBalance(
              symbol: widget.coin.getSymbol(),
              haveValue: widget.coin.isRpcWorking,
              balance: value,
            );
          },
        ),
      ),
    );
  }
}
