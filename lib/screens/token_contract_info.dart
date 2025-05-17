import 'package:wallet_app/interface/coin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../interface/ft_explorer.dart';
import '../utils/app_config.dart';
import '../utils/get_token_image.dart';
import 'launch_url.dart';

class TokenContractInfo extends StatelessWidget {
  final Coin coin;

  const TokenContractInfo({Key? key, required this.coin}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.tokenDetails,
        ),
      ),
      body: SizedBox(
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.token,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // if (coin is ERCFungibleCoin)
                          //   Identicon(
                          //     address: coin.contractAddress(),
                          //   )
                          // else
                          GetTokenImage(
                            currCoin: coin,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            coin.getSymbol(),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        localization.contractAddress,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        children: [
                          Text(
                            coin.tokenAddress()!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(
                                text: coin.tokenAddress()!,
                              ));

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localization.copiedToClipboard),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.copy,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        localization.symbol,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        coin.getSymbol(),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        localization.decimals,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${coin.decimals()}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        localization.network,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        coin.getDefault(),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith(
                                (states) => appBackgroundblue),
                            shape: WidgetStateProperty.resolveWith(
                              (states) => RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            textStyle: WidgetStateProperty.resolveWith(
                              (states) => const TextStyle(color: Colors.white),
                            ),
                          ),
                          child: Text(
                            localization.viewOnBlockExplorer,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () async {
                            if (coin is FTExplorer) {
                              final coin_ = coin as FTExplorer;
                              final url = coin_.contractExplorer();
                              await launchPageUrl(
                                context: context,
                                url: url,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
