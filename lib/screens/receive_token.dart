import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/eip/eip681.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/coin_pay.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pinput/pinput.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../interface/coin.dart';
import '../interface/ft_explorer.dart';
import 'launch_url.dart';

class ReceivePayParams {
  String? requestUrl;
  String? amount;

  ReceivePayParams({
    this.amount,
    this.requestUrl,
  });
}

class ReceiveToken extends StatefulWidget {
  final Coin coin;

  const ReceiveToken({Key? key, required this.coin}) : super(key: key);

  @override
  _ReceiveTokenState createState() => _ReceiveTokenState();
}

class _ReceiveTokenState extends State<ReceiveToken> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late String userAddress;
  TextEditingController amountCntrl = TextEditingController();
  ValueNotifier<ReceivePayParams> receiveParams =
      ValueNotifier<ReceivePayParams>(ReceivePayParams());
  late Coin coin;
  late AppLocalizations localizations;

  @override
  initState() {
    super.initState();
    coin = widget.coin;
  }

  Future<String> _getAddr() async {
    return await coin.getAddress();
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    amountCntrl.dispose();
    super.dispose();
  }

  _createPayment() {
    FocusManager.instance.primaryFocus?.unfocus();

    String amount = amountCntrl.text.trim();

    if (double.tryParse(amount) != null) {
      Decimal amountEntered = Decimal.parse(amount);
      final params = ReceivePayParams();

      try {
        if (coin is EthereumCoin) {
          EthereumCoin ethCoin = coin as EthereumCoin;
          String chainId = ethCoin.chainId.toString();
          int decimals = ethCoin.decimals();
          num powerDec = pow(
            10,
            decimals,
          );
          Decimal power = Decimal.parse(
            '$powerDec',
          );

          params.requestUrl = EIP681.build(
            targetAddress: coin.tokenAddress()!,
            chainId: chainId,
            functionName: 'transfer',
            parameters: {
              'uint256': '${amountEntered * power}',
              'address': userAddress
            },
          );
        } else if (coin is FTExplorer) {
        } else {
          // coin not tokens
          String coinScheme = coin.getPayScheme();
          params.requestUrl = CoinPay(
            coinScheme: coinScheme,
            amount: amountEntered.toDouble(),
            recipient: userAddress,
          ).toUri();
        }

        params.amount = "+$amount ${coin.getSymbol()}";
        receiveParams.value = params;
        amountCntrl.setText('');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${localizations.receive} ${coin.tokenAddress() != null ? ellipsify(str: coin.getSymbol()) : coin.getSymbol()}'),
        actions: [
          IconButton(
            onPressed: () async {
              final addressUrl = await coin.addressExplorer();

              await launchPageUrl(context: context, url: addressUrl);

              InAppWebView;
            },
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: FutureBuilder<String>(
              future: _getAddr(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                userAddress = snapshot.data!;

                return ValueListenableBuilder(
                  valueListenable: receiveParams,
                  builder: (context, ReceivePayParams _, child) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 270,
                          height: 270,
                          child: Card(
                            color: const Color(0xffF1F1F1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Align(
                              alignment: Alignment.center,
                              child: QrImageView(
                                padding: const EdgeInsets.all(10),
                                data: _.requestUrl ?? userAddress,
                                version: QrVersions.auto,
                                size: 250,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                          onTap: () async {
                            // copy to clipboard
                            await Clipboard.setData(ClipboardData(
                              text: userAddress,
                            ));

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations.copiedToClipboard,
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: colorForAddress,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userAddress,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Text(_.amount ?? ''),
                        const SizedBox(
                          height: 40,
                        ),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: localizations.sendOnly(
                                '${coin.tokenAddress() != null ? ellipsify(str: coin.getName()) : coin.getName()} (${coin.tokenAddress() != null ? ellipsify(str: coin.getSymbol()) : coin.getSymbol()})',
                              ),
                            ),
                          ]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    // copy to clipboard
                                    await Clipboard.setData(ClipboardData(
                                      text: userAddress,
                                    ));

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localizations.copiedToClipboard,
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: appPrimaryColor,
                                    ),
                                    child: const Icon(
                                      Icons.copy,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(localizations.copy),
                              ],
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                    onTap: () async {
                                      await Share.share(
                                          '${localizations.publicAddressToReceive} ${coin.getSymbol()} $userAddress');
                                    },
                                    child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: appPrimaryColor,
                                        ),
                                        child: const Icon(Icons.share,
                                            color: Colors.black))),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(localizations.share),
                              ],
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      AwesomeDialog(
                                        showCloseIcon: true,
                                        context: context,
                                        closeIcon: const Icon(
                                          Icons.close,
                                        ),
                                        animType: AnimType.scale,
                                        dialogType: DialogType.info,
                                        keyboardAware: true,
                                        body: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                localizations.requestPayment,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Material(
                                                elevation: 0,
                                                color: Colors.blueGrey
                                                    .withAlpha(40),
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller: amountCntrl,
                                                  autofocus: true,
                                                  minLines: 1,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    labelText:
                                                        localizations.amount,
                                                    prefixIcon: const Icon(
                                                        Icons.text_fields),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              AnimatedButton(
                                                isFixedHeight: false,
                                                text: localizations.ok,
                                                pressEvent: () {
                                                  _createPayment();
                                                  if (Navigator.canPop(
                                                      context)) {
                                                    Navigator.pop(context);
                                                  }
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ).show();
                                    },
                                    child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black,
                                        ),
                                        child: const Icon(Icons.add,
                                            color: Colors.white))),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(localizations.request),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
