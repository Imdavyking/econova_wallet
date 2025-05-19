import 'dart:async';
import 'dart:convert';

import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/format_money.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../components/user_balance.dart';
import '../interface/coin.dart';
import 'get_token_image.dart';

class GetBlockChainWidget extends StatefulWidget {
  final Widget cryptoAmount;

  final Coin coin;

  const GetBlockChainWidget({
    Key? key,
    required Coin coin_,
    required Widget cryptoAmount_,
  })  : coin = coin_,
        cryptoAmount = cryptoAmount_,
        super(key: key);

  @override
  State<GetBlockChainWidget> createState() => _GetBlockChainWidgetState();
}

class _GetBlockChainWidgetState extends State<GetBlockChainWidget> {
  Timer? timer;
  BlockchainPrice? cryptoInfo;
  bool useCache = true;
  ValueNotifier<double> coinWorth = ValueNotifier<double>(0);
  late Coin coin;

  @override
  void initState() {
    super.initState();
    coin = widget.coin;

    if (coin.getGeckoId().isNotEmpty) {
      getBlockchainPrice();
      timer = Timer.periodic(
        httpPollingDelay,
        (Timer t) async {
          try {
            await getBlockchainPrice();
          } catch (_) {}
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future getBlockchainPrice() async {
    try {
      Map allCryptoPrice = jsonDecode(
        await getCryptoPrice(
          useCache: useCache,
        ),
      ) as Map;

      if (useCache) useCache = false;

      final currencyWithSymbol = jsonDecode(currencyJson);

      final String defaultCurrency = pref.get('defaultCurrency') ?? "USD";
      final symbol = currencyWithSymbol[defaultCurrency]['symbol'];

      final Map cryptoMarket = allCryptoPrice[coin.getGeckoId()];

      final deCurrLow = defaultCurrency.toLowerCase();

      final currPrice = cryptoMarket[deCurrLow] as num;
      num? change = cryptoMarket['${deCurrLow}_24h_change'];
      final currChange = change ?? 0;

      Color color = Colors.grey;

      if (currChange > 0) {
        color = green;
      } else if (currChange < 0) {
        color = red;
      }

      coinWorth.value = await coin.getBalance(true) * currPrice;

      cryptoInfo = BlockchainPrice(
        pricewithSym: symbol + formatMoney(currPrice, true),
        change: currChange.toDouble(),
        changeSign: currChange > 0 ? '+' : '',
        symbol: symbol,
        color: color,
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (kDebugMode) {
        print(_);
      }
    }
  }

  Widget _buildPriceUI() {
    return Text(
      cryptoInfo!.changeSign +
          formatMoney(
            cryptoInfo!.change,
            true,
          ) +
          '%',
      style: TextStyle(
        fontSize: 12,
        color: cryptoInfo!.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              GetTokenImage(
                currCoin: coin,
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          coin.getSymbol(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.fade,
                        ),
                        widget.cryptoAmount
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (cryptoInfo != null)
                          Row(
                            children: [
                              Text(
                                cryptoInfo!.pricewithSym,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: coin.getGeckoId().isNotEmpty
                                      ? Colors.grey
                                      : const Color(0x00ffffff),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              if (cryptoInfo != null) _buildPriceUI()
                            ],
                          )
                        else
                          Row(
                            children: const [
                              Text(
                                '\$-',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                '-%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ValueListenableBuilder<double>(
                          valueListenable: coinWorth,
                          builder: (context, value, child) {
                            if (cryptoInfo == null) {
                              return const SizedBox();
                            }
                            return UserBalance(
                              symbol: cryptoInfo!.symbol,
                              haveValue: coin.isRpcWorking,
                              reversed: true,
                              balance: coinWorth.value,
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
              )
            ],
          ),
        ),
      ],
    );
  }
}

class BlockchainPrice {
  final String pricewithSym;

  final double change;
  final String changeSign;
  final String symbol;
  final Color color;

  BlockchainPrice({
    required this.pricewithSym,
    required this.change,
    required this.changeSign,
    required this.symbol,
    required this.color,
  });
}
