// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:math';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/config/colors.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../main.dart';
import '../model/transfer_trx_result.dart';
import '../service/crypto_transaction.dart';

class TransferToken extends StatefulWidget {
  final Coin coin;
  final String? cryptoDomain;
  final String recipient;
  final String amount;
  final String? memo;
  const TransferToken({
    super.key,
    required this.coin,
    this.cryptoDomain,
    required this.recipient,
    this.memo,
    required this.amount,
  });

  @override
  _TransferTokenState createState() => _TransferTokenState();
}

class _TransferTokenState extends State<TransferToken> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSending = false;
  late Timer timer;
  late SendTrxInfo trxInfo;
  late Coin coin;

  @override
  void initState() {
    super.initState();
    coin = widget.coin;
    trxInfo = SendTrxInfo(
      fee: 0,
      balance: 0,
      coin: coin,
    );
    getTransactionFee();
    timer = Timer.periodic(
      httpPollingDelay,
      (Timer t) async => await getTransactionFee(),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future getTransactionFee() async {
    try {
      trxInfo = await trxInfo.fetchInfo(
        widget.amount,
        widget.recipient,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    String trnFee = widget.coin.getDefault();
    bool haveTrx = false;
    if (trxInfo.fee != 0.0) {
      trnFee = '${Decimal.parse('${trxInfo.fee}')} $trnFee';
      haveTrx = true;
    }
    if (!haveTrx) {
      trnFee = '--- $trnFee';
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(localization.transfer)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '-${widget.amount} ${ellipsify(str: widget.coin.getSymbol())}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    localization.asset,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${ellipsify(str: widget.coin.getName())} (${ellipsify(str: widget.coin.getSymbol())})',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    localization.from,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<String>(future: () async {
                    return await widget.coin.getAddress();
                  }(), builder: (context, snapshot) {
                    return Text(
                      snapshot.hasData ? snapshot.data! : 'Loading...',
                      style: const TextStyle(fontSize: 16),
                    );
                  }),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    localization.to,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.cryptoDomain != null
                        ? '${widget.cryptoDomain} (${widget.recipient})'
                        : widget.recipient,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.memo != null) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      localization.memo,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.memo!,
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    localization.transactionFee,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    trnFee,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => appBackgroundblue),
                        shape: WidgetStateProperty.resolveWith(
                          (states) => RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: isSending
                          ? null
                          : () async {
                              if (isSending) return;
                              if (await authenticate(context)) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                if (mounted) {
                                  setState(() {
                                    isSending = true;
                                  });
                                }
                                try {
                                  String? transactionHash =
                                      await widget.coin.transferToken(
                                    widget.amount,
                                    widget.recipient,
                                    memo: widget.memo,
                                  );

                                  int coinDecimals = widget.coin.decimals();
                                  String userAddress =
                                      await widget.coin.getAddress();

                                  String trnxKey = widget.coin.savedTransKey();

                                  if (transactionHash == null) {
                                    throw Exception('Sending failed');
                                  }
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        localization.trxSent,
                                      ),
                                    ),
                                  );

                                  String tokenSent = widget.amount;
                                  final notiTitle =
                                      '${widget.coin.getSymbol()} Sent';
                                  final notiBody =
                                      '$tokenSent ${widget.coin.getSymbol()} sent to ${widget.recipient}';

                                  EventBusService.instance.fire(
                                    CryptoNotificationEvent(
                                      body: notiBody,
                                      title: notiTitle,
                                    ),
                                  );

                                  String formattedDate =
                                      DateFormat("yyyy-MM-dd HH:mm:ss").format(
                                    DateTime.now(),
                                  );

                                  final mapData = {
                                    'time': formattedDate,
                                    'from': userAddress,
                                    'to': widget.recipient,
                                    'value': double.parse(
                                          widget.amount,
                                        ) *
                                        pow(10, coinDecimals),
                                    'decimal': coinDecimals,
                                    'transactionHash': transactionHash
                                  };

                                  List userTransactions = [];
                                  String? jsonEncodedUsrTrx = pref.get(trnxKey);

                                  if (jsonEncodedUsrTrx != null) {
                                    userTransactions = json.decode(
                                      jsonEncodedUsrTrx,
                                    );
                                  }

                                  userTransactions.insert(0, mapData);
                                  userTransactions.length =
                                      maximumTransactionToSave;
                                  await pref.put(
                                    trnxKey,
                                    jsonEncode(userTransactions),
                                  );
                                  if (mounted) {
                                    setState(() {
                                      isSending = false;
                                    });
                                  }
                                  if (!context.mounted) return;
                                  if (Navigator.canPop(context)) {
                                    int count = 0;
                                    Navigator.popUntil(context, (route) {
                                      return count++ == 3;
                                    });
                                  }
                                } catch (e, sk) {
                                  if (kDebugMode) {
                                    print(e);
                                    print(sk);
                                  }
                                  if (mounted) {
                                    setState(() {
                                      isSending = false;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            e.toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      );
                                    });
                                  }
                                }
                              } else {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      localization.authFailed,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: isSending
                            ? Container(
                                color: Colors.transparent,
                                width: 20,
                                height: 20,
                                child: const Loader(color: black),
                              )
                            : Text(
                                localization.send,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
