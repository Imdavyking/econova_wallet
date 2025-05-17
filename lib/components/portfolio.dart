import 'dart:async';
import 'dart:convert';

import 'package:wallet_app/components/user_balance.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../main.dart';
import '../utils/app_config.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({Key? key}) : super(key: key);

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  Map? userBalance;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    getUserBalance();
    timer = Timer.periodic(
      httpPollingDelay,
      (Timer t) async => await getUserBalance(),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future getUserBalance() async {
    try {
      final allCryptoPrice = jsonDecode(
        await getCryptoPrice(
          skipNetworkRequest: true,
        ),
      ) as Map;

      final currencyWithSymbol = jsonDecode(currencyJson);

      final defaultCurrency = pref.get('defaultCurrency') ?? "USD";

      final symbol = currencyWithSymbol[defaultCurrency]['symbol'];

      double balance = await totalCryptoBalance(
        defaultCurrency: defaultCurrency,
        allCryptoPrice: allCryptoPrice,
      );
      if (mounted) {
        setState(() {
          userBalance = {
            'balance': balance,
            'symbol': symbol,
          };
        });
      }
    } catch (_, sk) {
      if (kDebugMode) {
        print(sk);
        print(_);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            // color: portfolioCardColor,
            color: Theme.of(context).brightness == Brightness.dark
                ? null
                : alterPrimaryColor,
            gradient: Theme.of(context).brightness == Brightness.light
                ? null
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      portfolioCardColor,
                      portfolioCardColorLowerSection
                    ],
                  ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          width: double.infinity,
          height: 150,
          child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.portfolio,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(255, 255, 255, .6),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (userBalance != null)
                      GestureDetector(
                        onTap: () async {
                          final userPreviousHidingBalance =
                              pref.get(hideBalanceKey, defaultValue: false);

                          await pref.put(
                              hideBalanceKey, !userPreviousHidingBalance);
                        },
                        child: SizedBox(
                          height: 35,
                          child: UserBalance(
                            symbol: userBalance!['symbol'],
                            balance: userBalance!['balance'],
                            reversed: true,
                            iconSize: 29,
                            iconDivider: const SizedBox(
                              width: 5,
                            ),
                            iconSuffix: const Icon(
                              FontAwesomeIcons.eyeSlash,
                              color: Colors.white,
                              size: 29,
                            ),
                            iconColor: Colors.white,
                            textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 35),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
