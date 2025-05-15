import 'package:cryptowallet/components/loader.dart';
import 'package:cryptowallet/interface/coin.dart';
import 'package:cryptowallet/utils/app_config.dart';
import 'package:cryptowallet/utils/qr_scan_view.dart';
import 'package:cryptowallet/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:cardano_wallet_sdk/cardano_wallet_sdk.dart' as cardano;
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';

import '../service/wallet_service.dart';

class UnStakeToken extends StatefulWidget {
  final Coin tokenData;
  final String? amount;
  final String? recipient;
  const UnStakeToken({
    required this.tokenData,
    Key? key,
    this.amount,
    this.recipient,
  }) : super(key: key);

  @override
  _UnStakeTokenState createState() => _UnStakeTokenState();
}

class _UnStakeTokenState extends State<UnStakeToken> {
  final amountContrl = TextEditingController();
  final memoContrl = TextEditingController();
  final tokenIdContrl = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  final bool showContacts = true;
  late Coin coin;

  @override
  void initState() {
    super.initState();
    coin = widget.tokenData;
    amountContrl.setText(widget.amount ?? '');
  }

  @override
  void dispose() {
    amountContrl.dispose();
    super.dispose();
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
            '${localization.unstakeToken} ${coin.tokenAddress() != null ? ellipsify(str: coin.getSymbol()) : coin.getSymbol()}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                TextFormField(
                  enabled: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.trim() == '') {
                      return localization.amountIsRequired;
                    } else {
                      return null;
                    }
                  },
                  controller: amountContrl,
                  decoration: InputDecoration(
                    suffixIconConstraints: const BoxConstraints(minWidth: 100),
                    suffixIcon: IconButton(
                      alignment: Alignment.centerRight,
                      icon: Text(
                        localization.max,
                        textAlign: TextAlign.end,
                      ),
                      onPressed: () async {
                        final stakedTokens = await coin.getStakedRewards();
                        amountContrl.setText(stakedTokens.toString());
                      },
                    ),
                    hintText: localization.amount,

                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none), // you
                    filled: true,
                  ),
                ),
                if (coin.requireMemo()) ...[
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    enabled: true,
                    controller: memoContrl,
                    decoration: InputDecoration(
                      suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.qr_code_scanner,
                            ),
                            onPressed: () async {
                              String? memo = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => const QRScanView(),
                                ),
                              );
                              if (memo == null) return;
                              memoContrl.setText(memo);
                            },
                          ),
                          InkWell(
                            onTap: () async {
                              ClipboardData? cdata =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              if (cdata == null) return;
                              if (cdata.text == null) return;
                              memoContrl.setText(cdata.text!);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                localization.paste,
                              ),
                            ),
                          ),
                        ],
                      ),

                      hintText: localization.memo,

                      focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide.none),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide.none),
                      enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide.none), // you
                      filled: true,
                    ),
                  ),
                ],
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => appBackgroundblue,
                      ),
                      shape: WidgetStateProperty.resolveWith(
                        (states) => RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textStyle: WidgetStateProperty.resolveWith(
                        (states) => const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    child: isLoading
                        ? const Loader()
                        : Text(
                            localization.continue_,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                    onPressed: () async {
                      if (isLoading) return;
                      ScaffoldMessenger.of(context).clearSnackBars();
                      FocusManager.instance.primaryFocus?.unfocus();
                      String amount = amountContrl.text.trim();
                      String? memo = memoContrl.text.trim();

                      if (double.tryParse(amount) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              localization.pleaseEnterAmount,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }

                      if (memo == '') memo = null;

                      try {
                        setState(() {
                          isLoading = true;
                        });
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        if (kDebugMode) {
                          print(e);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              localization.invalidAddress,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      if (amount == "") {
                        setState(() {
                          isLoading = false;
                        });
                        return;
                      }
                      ScaffoldMessenger.of(context).clearSnackBars();
                      if (WalletService.isPharseKey()) {
                        await reInstianteSeedRoot();
                      }

                      try {
                        final txHash =
                            await widget.tokenData.unstakeToken(amount);

                        if (txHash == null) {
                          throw Exception("Failed unstaking token");
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              localization.stake,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              localization.failedToUnStake,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      setState(() {
                        isLoading = false;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
