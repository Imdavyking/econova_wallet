// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/config/colors.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/model/transfer_trx_result.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../components/testnet_banner.dart';

// ── Shared label + value row used across all transfer screens ─────────────────

class TransferInfoRow extends StatelessWidget {
  final String label;
  final Widget value;

  const TransferInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        value,
        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Async address row (FutureBuilder) ────────────────────────────────────────

class TransferFromRow extends StatelessWidget {
  final Coin coin;
  final String label;

  const TransferFromRow({super.key, required this.coin, required this.label});

  @override
  Widget build(BuildContext context) {
    return TransferInfoRow(
      label: label,
      value: FutureBuilder<String>(
        future: coin.getAddress(),
        builder: (context, snapshot) => Text(
          snapshot.hasData ? snapshot.data! : 'Loading...',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// ── Shared transfer scaffold — handles timer, fee polling, auth, send ─────────

/// Wrap a transfer confirmation screen. Supply [rows] for the detail section
/// (asset, from, to, memo, tokenId, etc.) and [onSend] for the actual
/// coin-specific transfer call.
class ConfirmTransferScaffold extends StatefulWidget {
  final Coin coin;
  final String amount;
  final String recipient;
  final List<Widget> rows;
  final Future<({String txHash, String? txRaw})?> Function() onSend;
  final Future<void> Function({required String txHash})? onSuccess;

  const ConfirmTransferScaffold({
    super.key,
    required this.coin,
    required this.amount,
    required this.recipient,
    required this.rows,
    required this.onSend,
    this.onSuccess,
  });

  @override
  State<ConfirmTransferScaffold> createState() =>
      _ConfirmTransferScaffoldState();
}

class _ConfirmTransferScaffoldState extends State<ConfirmTransferScaffold> {
  bool _isSending = false;
  late Timer _timer;
  late SendTrxInfo _trxInfo;

  @override
  void initState() {
    super.initState();
    _trxInfo = SendTrxInfo(fee: 0, balance: 0, coin: widget.coin);
    _fetchFee();
    _timer = Timer.periodic(httpPollingDelay, (_) => _fetchFee());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchFee() async {
    try {
      _trxInfo = await _trxInfo.fetchInfo(widget.amount, widget.recipient);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_isSending) return;
    if (!await authenticate(context)) {
      if (!context.mounted) return;
      _showError(AppLocalizations.of(context)!.authFailed);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => _isSending = true);

    try {
      final result = await widget.onSend();
      if (result == null) throw Exception('Sending failed');

      if (widget.onSuccess != null) {
        await widget.onSuccess!(txHash: result.txHash);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.trxSent)),
      );
      setState(() => _isSending = false);
      if (context.mounted && Navigator.canPop(context)) {
        int count = 0;
        Navigator.popUntil(context, (_) => count++ == 3);
      }
    } catch (e, st) {
      if (kDebugMode) {
        print(e);
        print(st);
      }
      if (mounted && context.mounted) {
        setState(() => _isSending = false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    final bool hasFee = _trxInfo.fee != 0.0;
    final String feeDisplay = hasFee
        ? '${Decimal.parse('${_trxInfo.fee}')} ${widget.coin.getDefault()}'
        : '--- ${widget.coin.getDefault()}';

    return Scaffold(
      appBar: AppBar(title: Text(localization.transfer)),
      body: Column(
        children: [
          const TestnetBanner(),
          Expanded(
            child: SafeArea(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '-${widget.amount} ${ellipsify(str: widget.coin.getSymbol())}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ...widget.rows,
                        TransferInfoRow(
                          label: localization.transactionFee,
                          value: Text(feeDisplay,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (_) => appBackgroundblue),
                              shape: WidgetStateProperty.resolveWith(
                                (_) => RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            onPressed: _isSending ? null : _submit,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: _isSending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Loader(color: black),
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
                        ),
                      ],
                    ),
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
