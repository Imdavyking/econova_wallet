import 'dart:async';
import 'package:wallet_app/api/notification_api.dart';
import 'package:wallet_app/coins/nfts/multiv_nft_coin.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/config/colors.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../model/transfer_trx_result.dart';

class TransferMultiversxNFT extends StatefulWidget {
  final MultiversxNFTCoin coin;
  final String? cryptoDomain;
  final String recipient;
  final String amount;
  const TransferMultiversxNFT({
    Key? key,
    required this.coin,
    this.cryptoDomain,
    required this.recipient,
    required this.amount,
  }) : super(key: key);

  @override
  _TransferMultiversxNFTState createState() => _TransferMultiversxNFTState();
}

class _TransferMultiversxNFTState extends State<TransferMultiversxNFT> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSending = false;
  late Timer timer;
  late SendTrxInfo trxInfo;
  late MultiversxNFTCoin coin;

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
      trnFee = '${Decimal.parse('${trxInfo.fee}')} ' + trnFee;
      haveTrx = true;
    }
    if (!haveTrx) {
      trnFee = '--- ' + trnFee;
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
                    '-${widget.amount} ${ellipsify(str: coin.identifier)}',
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
                    '${ellipsify(str: coin.ticker)} (${ellipsify(str: coin.identifier)})',
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
                    return await coin.getAddress();
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
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    localization.tokenId,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    coin.identifier,
                    style: const TextStyle(fontSize: 16),
                  ),
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
                      onPressed: () async {
                        if (isSending) return;
                        if (await authenticate(context)) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          if (mounted) {
                            setState(() {
                              isSending = true;
                            });
                          }
                          try {
                            String? transactionHash = await coin.transferToken(
                              widget.amount,
                              widget.recipient,
                            );

                            if (transactionHash == null) {
                              throw Exception('Sending failed');
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localization.trxSent,
                                ),
                              ),
                            );

                            String tokenSent = '#${coin.identifier}';

                            NotificationApi.showNotification(
                              title: '${coin.getSymbol()} Sent',
                              body:
                                  '$tokenSent ${coin.getSymbol()} sent to ${widget.recipient}',
                            );

                            if (mounted) {
                              setState(() {
                                isSending = false;
                              });
                            }
                            if (Navigator.canPop(context)) {
                              int count = 0;
                              Navigator.popUntil(context, (route) {
                                return count++ == 2;
                              });
                            }
                            return;
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                isSending = false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      e.toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              });
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                localization.authFailed,
                                style: const TextStyle(color: Colors.white),
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
