// ignore_for_file: library_private_types_in_public_api

import 'package:wallet_app/screens/contact.dart';
import 'package:wallet_app/utils/qr_scan_view.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/coin_pay.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/eip/eip681.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';
import '../service/contact_service.dart';

// ── Shared border ─────────────────────────────────────────────────────────────

const _kRoundedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  borderSide: BorderSide.none,
);

InputDecoration sendFieldDecoration({
  String? hintText,
  Widget? suffixIcon,
  BoxConstraints? suffixIconConstraints,
}) =>
    InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      suffixIconConstraints: suffixIconConstraints,
      focusedBorder: _kRoundedBorder,
      border: _kRoundedBorder,
      enabledBorder: _kRoundedBorder,
      filled: true,
    );

// ── Recipient field ───────────────────────────────────────────────────────────

enum QrParseMode {
  /// EIP-681 (ERC token address in QR)
  eip681,

  /// CoinPay URI (native coins)
  coinPay,

  /// Both — try EIP-681 first, then CoinPay
  both,
}

class RecipientField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController? amountController;
  final TextEditingController? memoController;
  final QrParseMode qrMode;
  final bool showContacts;
  final bool showMemoFromContact;

  const RecipientField({
    super.key,
    required this.controller,
    this.amountController,
    this.memoController,
    this.qrMode = QrParseMode.both,
    this.showContacts = true,
    this.showMemoFromContact = false,
  });

  Future<void> _onQrScan(BuildContext context) async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScanView()),
    );
    if (scanned == null) return;

    // Plain address — no scheme
    if (!scanned.contains(':')) {
      controller.setText(scanned);
      return;
    }

    // EIP-681 attempt
    if (qrMode == QrParseMode.eip681 || qrMode == QrParseMode.both) {
      try {
        final data = EIP681.parse(scanned);
        controller.setText(data['parameters']['address'] as String);
        return;
      } catch (_) {}
    }

    // CoinPay attempt
    if (qrMode == QrParseMode.coinPay || qrMode == QrParseMode.both) {
      try {
        final data = CoinPay.parseUri(scanned);
        controller.setText(data.recipient);
        amountController?.setText(data.amount.toString());
        memoController?.setText('${data.memo}');
      } catch (_) {}
    }
  }

  Future<void> _onPaste() async {
    final cdata = await Clipboard.getData(Clipboard.kTextPlain);
    if (cdata?.text == null) return;
    controller.setText(cdata!.text!);
  }

  Future<void> _onPickContact(BuildContext context) async {
    final contact = await Navigator.push<ContactParams>(
      context,
      MaterialPageRoute(builder: (_) => const Contact(showAdd: false)),
    );
    if (contact == null) return;
    controller.setText(contact.address);
    if (showMemoFromContact) memoController?.setText(contact.memo ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TextFormField(
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      controller: controller,
      validator: (v) =>
          (v?.trim().isEmpty ?? true) ? l.receipientAddressIsRequired : null,
      decoration: sendFieldDecoration(
        hintText: '${l.receipientAddress} ${l.or} Domain Name',
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => _onQrScan(context),
            ),
            if (showContacts)
              IconButton(
                icon: const Icon(FontAwesomeIcons.user),
                onPressed: () => _onPickContact(context),
              ),
            InkWell(
              onTap: _onPaste,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(l.paste),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Amount field ──────────────────────────────────────────────────────────────

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final Future<double> Function()? onMax;
  final bool digitsOnly;

  const AmountField({
    super.key,
    required this.controller,
    this.onMax,
    this.digitsOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TextFormField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) => (v?.trim().isEmpty ?? true) ? l.amountIsRequired : null,
      inputFormatters:
          digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
      controller: controller,
      decoration: sendFieldDecoration(
        hintText: l.amount,
        suffixIconConstraints: const BoxConstraints(minWidth: 100),
        suffixIcon: onMax != null
            ? IconButton(
                alignment: Alignment.centerRight,
                icon: Text(l.max, textAlign: TextAlign.end),
                onPressed: () async {
                  final max = await onMax!();
                  controller.setText(max.toString());
                },
              )
            : null,
      ),
    );
  }
}

// ── Read-only token ID field ──────────────────────────────────────────────────

class TokenIdField extends StatelessWidget {
  final String tokenId;

  const TokenIdField({super.key, required this.tokenId});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: false,
      controller: TextEditingController(text: tokenId),
      decoration: sendFieldDecoration(),
    );
  }
}

// ── Continue button ───────────────────────────────────────────────────────────

class SendContinueButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SendContinueButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.resolveWith((_) => appBackgroundblue),
          shape: WidgetStateProperty.resolveWith(
            (_) =>
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const Loader()
            : Text(
                l.continue_,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
      ),
    );
  }
}
