import 'dart:async';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/format_money.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import '../components/user_balance.dart';
import '../interface/coin.dart';
import 'get_token_image.dart';

class GetBlockChainWidget extends StatefulWidget {
  final Widget cryptoAmount;
  final Coin coin;

  const GetBlockChainWidget({
    super.key,
    required Coin coin_,
    required Widget cryptoAmount_,
  })  : coin = coin_,
        cryptoAmount = cryptoAmount_;

  @override
  State<GetBlockChainWidget> createState() => _GetBlockChainWidgetState();
}

class _GetBlockChainWidgetState extends State<GetBlockChainWidget> {
  Timer? _timer;
  BlockchainPrice? _cryptoInfo;
  bool _useCache = true;
  final ValueNotifier<double> _coinWorth = ValueNotifier(0);
  late Coin _coin;

  @override
  void initState() {
    super.initState();
    _coin = widget.coin;
    if (_coin.getGeckoId().isNotEmpty) {
      _fetchPrice();
      _timer = Timer.periodic(httpPollingDelay, (_) async {
        try {
          await _fetchPrice();
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _coinWorth.dispose();
    super.dispose();
  }

  Future<void> _fetchPrice() async {
    try {
      final cryptoPrice = await getCryptoPrice(useCache: _useCache);
      if (_useCache) _useCache = false;

      final currPrice = cryptoPrice.getPrice(_coin.getGeckoId()) ?? 0.0;
      final currChange = cryptoPrice.getChange(_coin.getGeckoId()) ?? 0.0;

      Color color = Colors.grey;
      if (currChange > 0) color = green;
      if (currChange < 0) color = red;

      _coinWorth.value = await _coin.getBalance(true) * currPrice;

      _cryptoInfo = BlockchainPrice(
        pricewithSym: cryptoPrice.symbol + formatMoney(currPrice, true),
        change: currChange,
        changeSign: currChange > 0 ? '+' : '',
        symbol: cryptoPrice.symbol,
        color: color,
      );

      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              GetTokenImage(currCoin: _coin),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _coin.getSymbol(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                        widget.cryptoAmount,
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PriceChangeRow(info: _cryptoInfo, coin: _coin),
                        ValueListenableBuilder<double>(
                          valueListenable: _coinWorth,
                          builder: (context, value, _) {
                            if (_cryptoInfo == null) return const SizedBox();
                            return UserBalance(
                              symbol: _cryptoInfo!.symbol,
                              haveValue: _coin.isRpcWorking,
                              reversed: true,
                              balance: value,
                              seperate: false,
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Price + change row ─────────────────────────────────────────────────────────

class _PriceChangeRow extends StatelessWidget {
  final BlockchainPrice? info;
  final Coin coin;

  const _PriceChangeRow({required this.info, required this.coin});

  @override
  Widget build(BuildContext context) {
    if (info == null) {
      return const Row(
        children: [
          Text('\$0', style: TextStyle(fontSize: 15, color: Colors.grey)),
          SizedBox(width: 5),
          Text('0%', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      );
    }

    return Row(
      children: [
        Text(
          info!.pricewithSym,
          style: TextStyle(
            fontSize: 15,
            color: coin.getGeckoId().isNotEmpty
                ? Colors.grey
                : const Color(0x00ffffff),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '${info!.changeSign}${formatMoney(info!.change, true)}%',
          style: TextStyle(fontSize: 12, color: info!.color),
        ),
      ],
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class BlockchainPrice {
  final String pricewithSym;
  final double change;
  final String changeSign;
  final String symbol;
  final Color color;

  const BlockchainPrice({
    required this.pricewithSym,
    required this.change,
    required this.changeSign,
    required this.symbol,
    required this.color,
  });
}
