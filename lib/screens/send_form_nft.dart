// ignore_for_file: library_private_types_in_public_api

import 'package:wallet_app/coins/nfts/erc_nft_coin.dart';
import 'package:wallet_app/coins/nfts/multiv_nft_coin.dart';
import 'package:wallet_app/coins/nfts/starknet_nft_coin.dart';
import 'package:wallet_app/screens/send_form_widgets.dart';
import 'package:wallet_app/screens/transfer_nft.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';

// ── Shared NFT send form ──────────────────────────────────────────────────────

typedef _TransferBuilder = Widget Function({
  required String amount,
  required String recipient,
  String? cryptoDomain,
});

class _SendNFTForm extends StatefulWidget {
  final String title;
  final String tokenId;
  final String tokenType;
  final String semiFungibleType;
  final Future<double> Function() getMaxTransfer;
  final Future<String?> Function(String) resolveAddress;
  final void Function(String) validateAddress;
  final bool useEip681;
  final _TransferBuilder transferBuilder;
  final String? initialAmount;
  final String? initialRecipient;

  const _SendNFTForm({
    required this.title,
    required this.tokenId,
    required this.tokenType,
    required this.semiFungibleType,
    required this.getMaxTransfer,
    required this.resolveAddress,
    required this.validateAddress,
    required this.useEip681,
    required this.transferBuilder,
    this.initialAmount,
    this.initialRecipient,
  });

  @override
  State<_SendNFTForm> createState() => _SendNFTFormState();
}

class _SendNFTFormState extends State<_SendNFTForm> {
  final _recipientCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl.setText(widget.initialAmount ?? '');
    _recipientCtrl.setText(widget.initialRecipient ?? '');
  }

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _isSemiFungible => widget.tokenType == widget.semiFungibleType;

  Future<void> _onContinue() async {
    if (_isLoading) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    FocusManager.instance.primaryFocus?.unfocus();

    final l = AppLocalizations.of(context)!;

    if (!_isSemiFungible) _amountCtrl.setText('1');

    if (int.tryParse(_amountCtrl.text.trim()) == null) {
      _showError(l.pleaseEnterAmount);
      return;
    }

    String recipient = _recipientCtrl.text.trim();
    String? cryptoDomain;
    final isDomain = recipient.contains('.') || recipient.contains('@');

    try {
      setState(() => _isLoading = true);
      if (isDomain) {
        cryptoDomain = recipient;
        recipient = await widget.resolveAddress(recipient) ?? recipient;
      }
      setState(() => _isLoading = false);
      widget.validateAddress(recipient);
    } catch (e) {
      if (kDebugMode) print(e);
      setState(() => _isLoading = false);
      if (context.mounted) _showError(l.invalidAddress);
      return;
    }

    if (_amountCtrl.text.trim().isEmpty || recipient.isEmpty) return;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    await reInstianteSeedRoot();
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => widget.transferBuilder(
          amount: Decimal.parse(_amountCtrl.text).toString(),
          recipient: recipient,
          cryptoDomain: cryptoDomain,
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                RecipientField(
                  controller: _recipientCtrl,
                  amountController: _amountCtrl,
                  qrMode: widget.useEip681
                      ? QrParseMode.eip681
                      : QrParseMode.coinPay,
                ),
                if (_isSemiFungible) ...[
                  const SizedBox(height: 20),
                  AmountField(
                    controller: _amountCtrl,
                    onMax: widget.getMaxTransfer,
                    digitsOnly: true,
                  ),
                  const SizedBox(height: 20),
                  TokenIdField(tokenId: widget.tokenId),
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
    );
  }
}

// ── Public screens ────────────────────────────────────────────────────────────

class SendERCNFT extends StatelessWidget {
  final ERCNFTCoin coin;
  final String? amount;
  final String? recipient;

  const SendERCNFT(
      {required this.coin, super.key, this.amount, this.recipient});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _SendNFTForm(
      title: '${l.send} ${ellipsify(str: coin.getSymbol())}',
      tokenId: '${coin.tokenId}',
      tokenType: coin.tokenType,
      semiFungibleType: ERCFTTYPES.v1155,
      getMaxTransfer: coin.getMaxTransfer,
      resolveAddress: coin.resolveAddress,
      validateAddress: coin.validateAddress,
      useEip681: true,
      initialAmount: amount,
      initialRecipient: recipient,
      transferBuilder: ({required amount, required recipient, cryptoDomain}) =>
          ConfirmERCNFTTransfer(
        coin: coin,
        amount: amount,
        recipient: recipient,
        cryptoDomain: cryptoDomain,
      ),
    );
  }
}

class SendStarknetNFT extends StatelessWidget {
  final StarknetNFTCoin coin;
  final String? amount;
  final String? recipient;

  const SendStarknetNFT(
      {required this.coin, super.key, this.amount, this.recipient});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _SendNFTForm(
      title: '${l.send} ${ellipsify(str: coin.getSymbol())}',
      tokenId: '${coin.tokenId}',
      tokenType: coin.tokenType,
      semiFungibleType: ERCFTTYPES.v1155,
      getMaxTransfer: coin.getMaxTransfer,
      resolveAddress: coin.resolveAddress,
      validateAddress: coin.validateAddress,
      useEip681: true,
      initialAmount: amount,
      initialRecipient: recipient,
      transferBuilder: ({required amount, required recipient, cryptoDomain}) =>
          ConfirmStarknetNFTTransfer(
        coin: coin,
        amount: amount,
        recipient: recipient,
        cryptoDomain: cryptoDomain,
      ),
    );
  }
}

class SendMultiversxNFT extends StatelessWidget {
  final MultiversxNFTCoin coin;
  final String? amount;
  final String? recipient;

  const SendMultiversxNFT(
      {required this.coin, super.key, this.amount, this.recipient});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _SendNFTForm(
      title: '${l.send} ${ellipsify(str: coin.identifier)}',
      tokenId: coin.identifier,
      tokenType: coin.tokenType.name,
      semiFungibleType: MultivNFTType.SemiFungibleESDT.name,
      getMaxTransfer: coin.getMaxTransfer,
      resolveAddress: coin.resolveAddress,
      validateAddress: coin.validateAddress,
      useEip681: false,
      initialAmount: amount,
      initialRecipient: recipient,
      transferBuilder: ({required amount, required recipient, cryptoDomain}) =>
          ConfirmMultiversxNFTTransfer(
        coin: coin,
        amount: amount,
        recipient: recipient,
        cryptoDomain: cryptoDomain,
      ),
    );
  }
}
