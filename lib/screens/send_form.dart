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
import 'package:wallet_app/utils/zkproof.dart';

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
  bool _privateMode = false;
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
          isPrivate: _privateMode,
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
                      GestureDetector(
                        onTap: () async {
                          final info =
                              await ZkProofBridge.instance.generateProof({
                            "nullifier":
                                "0x866d86ccdbbbae15951539aa950076ac135982e49e139e6a8ad45488b7143f",
                            "secret":
                                "0xce2accb4d9c2befb72d19dc9c9497b494cb4cd7c186b8836ffcbc2e3c058ef",
                            "commitment":
                                "6968901238639841340449384697361615858797901214170004573979049867882899542618",
                            "recipient":
                                "GAPO2J457ED6JL2SP7DEUNJ7HRC47RA7ML6OJ4OPQ46HVW2BBZKCLNWC",
                            "commitments": [
                              "6968901238639841340449384697361615858797901214170004573979049867882899542618",
                            ],
                          });
                        },
                        child: Container(
                          color: Colors.red,
                          height: 12,
                          width: 12,
                        ),
                      ),
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
                          try {
                            _coin.validateAddress(addr);
                          } catch (e) {
                            return const SizedBox.shrink();
                          }

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
                                _coin.getExplorerIdenticon(addr, size: 36) ??
                                    const SizedBox.shrink(),
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
                      if (_coin.supportsPrivateSend) ...[
                        const SizedBox(height: 16),
                        _PrivateToggle(
                          value: _privateMode,
                          onChanged: (v) => setState(() => _privateMode = v),
                        ),
                      ],
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

class _PrivateToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivateToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? Colors.indigo.withOpacity(0.12)
              : Theme.of(context).inputDecorationTheme.fillColor ??
                  Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border:
              value ? Border.all(color: Colors.indigo.withOpacity(0.4)) : null,
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.lock : Icons.lock_open,
              size: 18,
              color: value ? Colors.indigo : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value ? 'Private send' : 'Regular send',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: value ? Colors.indigo : null,
                    ),
                  ),
                  if (value)
                    const Text(
                      'Sent in \$1 increments · amount rounded down',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }
}
