import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/screens/contact.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/coin_pay.dart';
import 'package:wallet_app/utils/qr_scan_view.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinput/pinput.dart';
import '../coins/nfts/multiv_nft_coin.dart';

// import 'package:cardano_wallet_sdk/cardano_wallet_sdk.dart' as cardano;
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../screens/transfer_multiversxNFT.dart';
import '../service/contact_service.dart';

class SendMultiversxNFT extends StatefulWidget {
  final MultiversxNFTCoin coin;
  final String? amount;
  final String? recipient;
  const SendMultiversxNFT({
    required this.coin,
    Key? key,
    this.amount,
    this.recipient,
  }) : super(key: key);

  @override
  _SendMultiversxNFTState createState() => _SendMultiversxNFTState();
}

class _SendMultiversxNFTState extends State<SendMultiversxNFT> {
  final recipientContrl = TextEditingController();
  final amountContrl = TextEditingController();
  final tokenIdContrl = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  final bool showContacts = true;

  @override
  void initState() {
    super.initState();
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
            '${localization.send} ${ellipsify(str: widget.coin.identifier)}'),
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
                              CoinPay data = CoinPay.parseUri(recipientAddr);
                              recipientContrl.setText(data.recipient);
                              amountContrl.setText(data.amount.toString());
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
                        '${localization.receipientAddress} ${localization.or} Domain Name',

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
                if (widget.coin.tokenType ==
                    MultivNFTType.SemiFungibleESDT) ...[
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
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    controller: amountContrl,
                    decoration: InputDecoration(
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 100),
                      suffixIcon: IconButton(
                        alignment: Alignment.centerRight,
                        icon: Text(
                          localization.max,
                          textAlign: TextAlign.end,
                        ),
                        onPressed: () async {
                          final maxTransfer =
                              await widget.coin.getMaxTransfer();
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
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    enabled: false,
                    validator: (value) {
                      if (value?.trim() == '') {
                        return localization.amountIsRequired;
                      } else {
                        return null;
                      }
                    },
                    controller: tokenIdContrl..text = widget.coin.identifier,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide.none),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
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
                      MultivNFTType erctokenType = widget.coin.tokenType;

                      if (erctokenType == MultivNFTType.NonFungibleESDT) {
                        amountContrl.setText('1');
                      }

                      int? amounToSend = int.tryParse(amountContrl.text.trim());

                      if (amounToSend == null) {
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

                      String? recipient = recipientContrl.text.trim();
                      String? cryptoDomain;
                      bool iscryptoDomain =
                          recipient.contains('.') || recipient.contains('@');

                      try {
                        setState(() {
                          isLoading = true;
                        });

                        if (iscryptoDomain) {
                          cryptoDomain = recipient;
                          recipient =
                              await widget.coin.resolveAddress(recipient);
                        }

                        setState(() {
                          isLoading = false;
                        });

                        widget.coin.validateAddress(recipient!);
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
                      if (amountContrl.text.trim() == "" || recipient == "") {
                        return;
                      }

                      ScaffoldMessenger.of(context).clearSnackBars();
                      await reInstianteSeedRoot();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => TransferMultiversxNFT(
                            amount: Decimal.parse(amountContrl.text).toString(),
                            recipient: recipient!,
                            coin: widget.coin,
                            cryptoDomain: cryptoDomain,
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
