// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:math';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/screens/confirm_transfer_scaffold.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:intl/intl.dart';
import 'package:wallet_app/utils/zkproof.dart';

import '../main.dart';
import '../service/crypto_transaction.dart';

class ConfirmTransfer extends StatelessWidget {
  final Coin coin;
  final String? cryptoDomain;
  final String recipient;
  final String amount;
  final String? memo;
  final bool isPrivate;

  const ConfirmTransfer({
    super.key,
    required this.coin,
    this.isPrivate = false,
    this.cryptoDomain,
    required this.recipient,
    this.memo,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final privateAmount =
        isPrivate ? double.parse(amount).floor().toDouble() : null;

    return ConfirmTransferScaffold(
      coin: coin,
      amount: isPrivate ? privateAmount.toString() : amount,
      recipient: recipient,
      onSend: () async {
        return isPrivate
            ? coin.transferTokenPrivate(amount, recipient)
            : coin.transferToken(amount, recipient, memo: memo);
      },
      onSuccess: ({required txHash}) async {
        final coinDecimals = coin.decimals();
        final userAddress = await coin.getAddress();
        final trnxKey = coin.savedTransKey();
        final formattedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        final mapData = {
          'time': formattedDate,
          'from': userAddress,
          'to': recipient,
          'value': double.parse(amount) * pow(10, coinDecimals),
          'decimal': coinDecimals,
          'transactionHash': txHash,
        };

        List userTransactions = [];
        final existing = pref.get(trnxKey);
        if (existing != null) {
          userTransactions = jsonDecode(existing);
        }
        userTransactions.insert(0, mapData);
        if (userTransactions.length > maximumTransactionToSave) {
          userTransactions.length = maximumTransactionToSave;
        }
        await pref.put(trnxKey, jsonEncode(userTransactions));

        EventBusService.instance.fire(CryptoNotificationEvent(
          title: '${coin.getSymbol()} Sent',
          body: '$amount ${coin.getSymbol()} sent to $recipient',
        ));
      },
      rows: [
        TransferInfoRow(
          label: localization.asset,
          value: Text(
            '${ellipsify(str: coin.getName())} (${ellipsify(str: coin.getSymbol())})',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TransferFromRow(coin: coin, label: localization.from),
        TransferInfoRow(
          label: localization.to,
          value: Text(
            cryptoDomain != null ? '$cryptoDomain ($recipient)' : recipient,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        if (memo != null)
          TransferInfoRow(
            label: localization.memo,
            value: Text(memo!, style: const TextStyle(fontSize: 16)),
          ),
      ],
    );
  }
}
