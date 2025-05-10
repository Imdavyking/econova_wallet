import 'package:cryptowallet/components/loader.dart';
import 'package:cryptowallet/eip/eip681.dart';
import 'package:cryptowallet/interface/coin.dart';
import 'package:cryptowallet/screens/contact.dart';
import 'package:cryptowallet/screens/transfer_token.dart';
import 'package:cryptowallet/service/contact_service.dart';
import 'package:cryptowallet/utils/app_config.dart';
import 'package:cryptowallet/utils/coin_pay.dart';
import 'package:cryptowallet/utils/qr_scan_view.dart';
import 'package:cryptowallet/utils/rpc_urls.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import 'package:cardano_wallet_sdk/cardano_wallet_sdk.dart' as cardano;
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';

import '../service/wallet_service.dart';

class SendToken extends StatefulWidget {
  final Coin tokenData;
  final String? amount;
  final String? recipient;
  const SendToken({
    required this.tokenData,
    Key? key,
    this.amount,
    this.recipient,
  }) : super(key: key);

  @override
  _SendTokenState createState() => _SendTokenState();
}

class _SendTokenState extends State<SendToken> {
  final recipientContrl = TextEditingController();
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
    recipientContrl.setText(widget.recipient ?? '');
  }

  @override
  void dispose() {
    amountContrl.dispose();
    recipientContrl.dispose();
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
            '${localization.send} ${coin.tokenAddress() != null ? ellipsify(str: coin.getSymbol()) : coin.getSymbol()}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value?.trim() == '') {
                      return localization.receipientAddressIsRequired;
                    } else {
                      return null;
                    }
                  },
                  controller: recipientContrl,
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
                            String? recipientAddr = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const QRScanView(),
                              ),
                            );

                            if (recipientAddr == null) return;

                            if (!recipientAddr.contains(':')) {
                              recipientContrl.setText(recipientAddr);
                            }

                            try {
                              if (coin.tokenAddress() != null) {
                                Map data = EIP681.parse(recipientAddr);

                                recipientContrl
                                    .setText(data['parameters']['address']);
                                return;
                              }
                            } catch (_) {}

                            try {
                              CoinPay data = CoinPay.parseUri(recipientAddr);
                              recipientContrl.setText(data.recipient);
                              amountContrl.setText('${data.amount}');
                              memoContrl.setText('${data.memo}');
                            } catch (_) {}
                          },
                        ),
                        if (showContacts)
                          IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.user,
                            ),
                            onPressed: () async {
                              ContactParams? contact = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      const Contact(showAdd: false),
                                ),
                              );

                              if (contact == null) return;
                              recipientContrl.setText(contact.address!);
                              memoContrl.setText(contact.memo!);
                            },
                          ),
                        InkWell(
                          onTap: () async {
                            ClipboardData? cdata =
                                await Clipboard.getData(Clipboard.kTextPlain);
                            if (cdata == null) return;
                            if (cdata.text == null) return;
                            recipientContrl.setText(cdata.text!);
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
                    hintText:
                        '${localization.receipientAddress} ${localization.receipientAddress} ${localization.or} Domain Name',

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
                const SizedBox(
                  height: 20,
                ),
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
                        final maxTransfer = await coin.getMaxTransfer();
                        amountContrl.setText(maxTransfer.toString());
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

                      String? recipient = recipientContrl.text.trim();
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
                      String? cryptoDomain;
                      bool iscryptoDomain =
                          recipient.contains('.') || recipient.contains('@');

                      try {
                        setState(() {
                          isLoading = true;
                        });

                        if (iscryptoDomain) {
                          cryptoDomain = recipient;
                          recipient = await coin.resolveAddress(recipient);
                        }

                        coin.validateAddress(recipient!);
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
                      if (amount == "" || recipient == "") {
                        setState(() {
                          isLoading = false;
                        });
                        return;
                      }
                      ScaffoldMessenger.of(context).clearSnackBars();
                      if (WalletService.isPharseKey()) {
                        await reInstianteSeedRoot();
                      }

                      setState(() {
                        isLoading = false;
                      });
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => TransferToken(
                            amount: Decimal.parse(amountContrl.text).toString(),
                            recipient: recipient!,
                            coin: coin,
                            cryptoDomain: cryptoDomain,
                            memo: memo,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
