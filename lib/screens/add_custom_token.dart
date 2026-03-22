// ignore_for_file: library_private_types_in_public_api

import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/screens/select_blockchain.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';

import '../coins/fungible_tokens/erc_fungible_coin.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';
import '../utils/qr_scan_view.dart';

class AddCustomToken extends StatefulWidget {
  const AddCustomToken({super.key});

  @override
  _AddCustomTokenState createState() => _AddCustomTokenState();
}

class _AddCustomTokenState extends State<AddCustomToken> {
  final _contractCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _symbolCtrl = TextEditingController();
  final _decimalCtrl = TextEditingController();

  final ValueNotifier<EthereumCoin> _coinNotifier =
      ValueNotifier<EthereumCoin>(evmChains[0]);

  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _contractCtrl.addListener(_onContractChanged);
  }

  @override
  void dispose() {
    _contractCtrl.removeListener(_onContractChanged);
    _contractCtrl.dispose();
    _nameCtrl.dispose();
    _symbolCtrl.dispose();
    _decimalCtrl.dispose();
    _coinNotifier.dispose();
    super.dispose();
  }

  // ── Auto-fill ─────────────────────────────────────────────────────────────

  void _onContractChanged() {
    _autoFill(_contractCtrl.text.trim());
  }

  void _clearFields() {
    _nameCtrl.setText('');
    _symbolCtrl.setText('');
    _decimalCtrl.setText('');
  }

  Future<void> _autoFill(String contractAddr) async {
    _clearFields();
    if (contractAddr.isEmpty) return;

    setState(() => _loading = true);
    try {
      final coin = ERCFungibleCoin(
        contractAddress_: contractAddr,
        geckoID: '',
        rpc: _coinNotifier.value.rpc,
        blockExplorer: _coinNotifier.value.blockExplorer,
        image: _coinNotifier.value.image,
        chainId: _coinNotifier.value.chainId,
        coinType: _coinNotifier.value.coinType,
        default_: _coinNotifier.value.default_,
        mintDecimals: 18,
        name: '',
        symbol: '',
      );
      final meta = await coin.getERC20Meta();
      if (meta == null) return;
      _nameCtrl.setText(meta.name);
      _symbolCtrl.setText(meta.symbol);
      _decimalCtrl.setText(meta.decimals.toString());
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Validation ────────────────────────────────────────────────────────────

  String? _validate() {
    final localization = AppLocalizations.of(context)!;
    final addr = _contractCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final symbol = _symbolCtrl.text.trim();
    final decimal = _decimalCtrl.text.trim();

    if (addr.isEmpty || name.isEmpty || symbol.isEmpty || decimal.isEmpty) {
      return localization.enterContractAddress;
    }

    if (int.tryParse(decimal) == null) {
      return localization.decimals;
    }

    final coin = _coinNotifier.value;
    final alreadyExists = erc20Coins.any((c) =>
        c.tokenAddress().toLowerCase() == addr.toLowerCase() &&
        c.chainId == coin.chainId);

    if (alreadyExists) return localization.tokenImportedAlready;

    return null;
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // If fields are empty, try to auto-fill first
    final name = _nameCtrl.text.trim();
    final symbol = _symbolCtrl.text.trim();
    final decimal = _decimalCtrl.text.trim();
    if (name.isEmpty || symbol.isEmpty || decimal.isEmpty) {
      await _autoFill(_contractCtrl.text.trim());
      return;
    }

    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => _saving = true);
    try {
      final coin = _coinNotifier.value;
      final ethToken = ERCFungibleCoin(
        contractAddress_: _contractCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        geckoID: '',
        symbol: _symbolCtrl.text.trim(),
        mintDecimals: int.parse(_decimalCtrl.text.trim()),
        chainId: coin.chainId,
        rpc: coin.rpc,
        blockExplorer: coin.blockExplorer,
        coinType: coin.coinType,
        default_: coin.default_,
        image: 'assets/ethereum-2.png',
      );

      final added = await ethToken.addCoinToStore();
      if (!mounted) return;

      if (!added) {
        _showError(AppLocalizations.of(context)!.tokenImportedAlready);
        return;
      }

      supportedChains.add(ethToken);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Wallet()),
        (r) => false,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(localization.addToken, style: const TextStyle(fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Network selector
              _NetworkSelector(
                  coinNotifier: _coinNotifier,
                  onChanged: () {
                    _clearFields();
                    if (_contractCtrl.text.trim().isNotEmpty) {
                      _autoFill(_contractCtrl.text.trim());
                    }
                  }),
              const SizedBox(height: 40),
              // Contract address
              _RoundedField(
                controller: _contractCtrl,
                hint: localization.enterContractAddress,
                suffix: _InputSuffix(
                  controller: _contractCtrl,
                  pasteLabel: localization.paste,
                ),
              ),
              const SizedBox(height: 12),
              // Loading indicator while fetching token metadata
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
              const SizedBox(height: 8),
              // Auto-filled read-only fields
              _RoundedField(
                controller: _nameCtrl,
                hint: localization.name,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              _RoundedField(
                controller: _symbolCtrl,
                hint: localization.symbol,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              _RoundedField(
                controller: _decimalCtrl,
                hint: localization.decimals,
                readOnly: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              // Scam warning
              const _ScamWarning(),
              const SizedBox(height: 40),
              // Save button
              _SaveButton(
                label: localization.done,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Network selector ──────────────────────────────────────────────────────────

class _NetworkSelector extends StatelessWidget {
  final ValueNotifier<EthereumCoin> coinNotifier;
  final VoidCallback onChanged;

  const _NetworkSelector({
    required this.coinNotifier,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localization.network,
          style: const TextStyle(fontSize: 20),
        ),
        GestureDetector(
          onTap: () async {
            final coin = await Navigator.push<Coin>(
              context,
              MaterialPageRoute(
                builder: (_) => SelectBlockchain(
                  filterFn: (c) =>
                      c is EthereumCoin && c.tokenAddress() == null,
                ),
              ),
            );
            if (coin is EthereumCoin) {
              coinNotifier.value = coin;
              onChanged();
            }
          },
          child: ValueListenableBuilder<EthereumCoin>(
            valueListenable: coinNotifier,
            builder: (_, coin, __) => Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(coin.getImage()),
                ),
                const SizedBox(width: 8),
                Text(
                  coin.getName(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Rounded text field ────────────────────────────────────────────────────────

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _RoundedField({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
  });

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        focusedBorder: _border,
        border: _border,
        enabledBorder: _border,
      ),
    );
  }
}

// ── QR + paste suffix ─────────────────────────────────────────────────────────

class _InputSuffix extends StatelessWidget {
  final TextEditingController controller;
  final String pasteLabel;

  const _InputSuffix({
    required this.controller,
    required this.pasteLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (_) => const QRScanView()),
            );
            if (result != null) controller.setText(result);
          },
        ),
        InkWell(
          onTap: () async {
            final data = await Clipboard.getData(Clipboard.kTextPlain);
            final text = data?.text;
            if (text != null && text.isNotEmpty) controller.setText(text);
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(pasteLabel),
          ),
        ),
      ],
    );
  }
}

// ── Scam warning ──────────────────────────────────────────────────────────────

class _ScamWarning extends StatelessWidget {
  const _ScamWarning();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.red[50],
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.anyoneCanCreateToken,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localization.includingScamTokens,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Save button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: appBackgroundblue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}
