import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/components/user_balance.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/screens/token.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';
import 'package:wallet_app/utils/get_blockchain_widget.dart';
import 'package:wallet_app/utils/rpc_urls.dart';

class WalletCoinListItem extends StatefulWidget {
  final Coin coin;
  const WalletCoinListItem({super.key, required this.coin});

  @override
  State<WalletCoinListItem> createState() => _WalletCoinListItemState();
}

class _WalletCoinListItemState extends State<WalletCoinListItem> {
  final ValueNotifier<double?> _balanceNotifier = ValueNotifier(null);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _timer = Timer.periodic(httpPollingDelay, (_) => _loadBalance());
  }

  Future<void> _loadBalance() async {
    try {
      final balance =
          await widget.coin.getBalance(_balanceNotifier.value == null);
      if (mounted) _balanceNotifier.value = balance;
      await DeadManSwitchService.recordActivity();
      final pubKey = await widget.coin.getPublicKey();
      if (widget.coin is! EthereumCoin || pubKey == null) return;
      final shares = await DeadManSwitchService.fetchSharesFromRelay(
        beneficiaryPublicKeyHex: pubKey,
      );
      debugPrint('shares: $shares');
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _balanceNotifier.dispose();
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
