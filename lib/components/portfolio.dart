import 'dart:async';

import 'package:wallet_app/components/user_balance.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../main.dart';
import '../utils/app_config.dart';

class UserBalDetails {
  final String symbol;
  final double balance;
  const UserBalDetails({
    required this.symbol,
    required this.balance,
  });
}

class Portfolio extends StatefulWidget {
  const Portfolio({super.key});

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  UserBalDetails? userBalance;
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
      final cryptoPrice = await getCryptoPrice(useCache: true);

      double balance = await totalCryptoBalance(
        cryptoPrice: cryptoPrice,
      );

      if (mounted) {
        setState(() {
          userBalance =
              UserBalDetails(symbol: cryptoPrice.symbol, balance: balance);
        });
      }
    } catch (_, sk) {
      if (kDebugMode) {
        print(sk);
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
                          final userBalHidden =
                              pref.get(hideBalanceKey, defaultValue: false);
                          if (userBalHidden) {
                            final auth = await authenticate(context);
                            if (!auth) return;
                          }
                          await pref.put(hideBalanceKey, !userBalHidden);
                        },
                        child: SizedBox(
                          height: 35,
                          child: UserBalance(
                            symbol: userBalance!.symbol,
                            balance: userBalance!.balance,
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
                              fontWeight: FontWeight.bold,
                            ),
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
