// ignore_for_file: library_private_types_in_public_api

import 'package:wallet_app/components/testnet_banner.dart';
import 'package:wallet_app/extensions/first_or_null.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/screens/send_form_widgets.dart';
import 'package:wallet_app/screens/confirm_transfer.dart';
import 'package:wallet_app/service/contact_service.dart';
import 'package:wallet_app/utils/qr_scan_view.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';

import '../service/wallet_service.dart';

class SendForm extends StatefulWidget {
  final Coin tokenData;
  final String? amount;
  final String? recipient;

  const SendForm({
    required this.tokenData,
    super.key,
    this.amount,
    this.recipient,
  });

  @override
  _SendFormState createState() => _SendFormState();
}

class _SendFormState extends State<SendForm> {
  final _recipientCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  bool _isLoading = false;
  late Coin _coin;

  @override
  void initState() {
    super.initState();
    _coin = widget.tokenData;
    _amountCtrl.setText(widget.amount ?? "");
    _recipientCtrl.setText(widget.recipient ?? "");
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _recipientCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_isLoading) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    FocusManager.instance.primaryFocus?.unfocus();

    String recipient = _recipientCtrl.text.trim();
    final amount = _amountCtrl.text.trim();
    final memoRaw = _memoCtrl.text.trim();
    String? memo = memoRaw.isEmpty ? null : memoRaw;

    final l = AppLocalizations.of(context)!;

    if (double.tryParse(amount) == null) {
      _showError(l.pleaseEnterAmount);
      return;
    }

    String? cryptoDomain;
    final isDomain = recipient.contains(".") || recipient.contains("@");

    try {
      setState(() => _isLoading = true);
      if (isDomain) {
        cryptoDomain = recipient;
        recipient = await _coin.resolveAddress(recipient) ?? recipient;
      }
      _coin.validateAddress(recipient);
    } catch (e) {
      if (true) debugPrint(e.toString()); // kDebugMode
      setState(() => _isLoading = false);
      if (context.mounted) _showError(l.invalidAddress);
      return;
    }

    if (amount.isEmpty || recipient.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (WalletService.isBip39PhraseOrSeedHexKey()) await reInstianteSeedRoot();
    setState(() => _isLoading = false);

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmTransfer(
          amount: Decimal.parse(_amountCtrl.text).toString(),
          recipient: recipient,
          coin: _coin,
          cryptoDomain: cryptoDomain,
          memo: memo,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final symbol = _coin.tokenAddress() != null
        ? ellipsify(str: _coin.getSymbol())
        : _coin.getSymbol();

    return Scaffold(
      appBar: AppBar(title: Text("${l.send} $symbol")),
      body: Column(
        children: [
          const TestnetBanner(),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      RecipientField(
                        controller: _recipientCtrl,
                        amountController: _amountCtrl,
                        memoController: _memoCtrl,
                        qrMode: _coin.tokenAddress() != null
                            ? QrParseMode.eip681
                            : QrParseMode.both,
                        showMemoFromContact: true,
                        coin: _coin,
                      ),
                      // Replace the ValueListenableBuilder you had before with this:
                      ValueListenableBuilder(
                        valueListenable: _recipientCtrl,
                        builder: (context, ctrl, _) {
                          final addr = ctrl.text.trim();
                          if (addr.isEmpty) return const SizedBox.shrink();

                          // Look up contact first
                          final contact =
                              ContactService.getContactsForCoin(_coin)
                                  .firstWhereOrNull(
                            (c) =>
                                c.address.toLowerCase() == addr.toLowerCase(),
                          );

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                _coin.getIdenticon(addr, size: 36) ??
                                    Container(),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: contact != null
                                      // ── Known contact — show name prominently ──────────────
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              contact.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              ellipsify(str: addr),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        )
                                      // ── Unknown address — just show truncated address ───────
                                      : Text(
                                          ellipsify(str: addr),
                                          style: const TextStyle(
                                              fontSize: 13, color: Colors.grey),
                                        ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      AmountField(
                        controller: _amountCtrl,
                        onMax: () => _coin.getMaxTransfer(),
                      ),
                      if (_coin.requireMemo()) ...[
                        const SizedBox(height: 20),
                        _MemoField(controller: _memoCtrl, localization: l),
                      ],
                      const SizedBox(height: 30),
                      SendContinueButton(
                        isLoading: _isLoading,
                        onPressed: _onContinue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations localization;

  const _MemoField({required this.controller, required this.localization});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: sendFieldDecoration(
        hintText: localization.memo,
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () async {
                final memo = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScanView()),
                );
                if (memo != null) controller.setText(memo);
              },
            ),
            InkWell(
              onTap: () async {
                final cdata = await Clipboard.getData(Clipboard.kTextPlain);
                if (cdata?.text != null) controller.setText(cdata!.text!);
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(localization.paste),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
