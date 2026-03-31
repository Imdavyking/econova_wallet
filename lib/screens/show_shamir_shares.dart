// ignore_for_file: library_private_types_in_public_api

import 'package:bip39/bip39.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:slip39/slip39.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/model/seed_phrase_root.dart';
import 'package:wallet_app/utils/app_config.dart';

class ShowShamirShares extends StatefulWidget {
  final String data;

  const ShowShamirShares({super.key, required this.data});

  @override
  State<ShowShamirShares> createState() => _ShowShamirSharesState();
}

class _ShowShamirSharesState extends State<ShowShamirShares> {
  // ── Controllers & state ────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _thresholdCtrl = TextEditingController();
  final _sharesCtrl = TextEditingController();
  final _passphraseCtrl = TextEditingController();
  final _sharesList = ValueNotifier<List<String>>([]);
  Map<String, Uint8List> cacheSeed = {};
  Iterable<Column> bip39supported = [];
  static const _maxShares = 8;
  static const _minShares = 2;
  bool validSeedPhrase = false;

  Future<void> _checkValidSeed() async {
    validSeedPhrase = await compute(validateMnemonic, widget.data);
    if (mounted) setState(() {});
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    bip39supported = getChains().map((e) {
      if (!e.supportBip39Seed && e.tokenAddress() == null) {
        return Column(
          children: [
            Text(
              '${e.getName()} (${e.getSymbol()}) do not support BIP39 seed, you may not be able to recover your address',
            ),
            const SizedBox(height: 10),
          ],
        );
      }
      return null;
    }).nonNulls;
    _checkValidSeed();
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    _sharesCtrl.dispose();
    _passphraseCtrl.dispose();
    _sharesList.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────────────────────

  void _generateShares() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final minimum = int.parse(_thresholdCtrl.text.trim());
    final shares = int.parse(_sharesCtrl.text.trim());

    if (!cacheSeed.containsKey(widget.data)) {
      final seeds = await compute(seedFromMnemonic, widget.data);
      cacheSeed[widget.data] = seeds.seed;
    }

    final slip = Slip39.from(
      [
        [minimum, shares]
      ],
      masterSecret: cacheSeed[widget.data]!,
      passphrase: _passphraseCtrl.text.trim(),
      threshold: 1,
    );
    _sharesList.value = slip.fromPath('r/0').mnemonics;
  }

  String? _validateThreshold(String? v, AppLocalizations loc) {
    if (v == null || v.trim().isEmpty) return loc.enterValidthresholdCount;
    final threshold = int.tryParse(v);
    if (threshold == null || threshold <= 0) return loc.enterValidthresholdCount;
    final shares = int.tryParse(_sharesCtrl.text.trim());
    if (shares == null) return loc.enterValidsharesCount;
    if (threshold > shares) return loc.enterValidthresholdCount;
    return null;
  }

  String? _validateShares(String? v, AppLocalizations loc) {
    if (v == null || v.trim().isEmpty) return loc.enterValidsharesCount;
    final shares = int.tryParse(v);
    if (shares == null) return loc.enterValidsharesCount;
    if (shares > _maxShares) return loc.maxSharesError;
    if (shares < _minShares) return loc.minSharesError;
    return null;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('SLIP39')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Threshold input
                _NumberField(
                  controller: _thresholdCtrl,
                  hint: loc.thresholdCount,
                  validator: (v) => _validateThreshold(v, loc),
                ),
                const SizedBox(height: 20),

                // Shares count input
                _NumberField(
                  controller: _sharesCtrl,
                  hint: loc.sharesCount,
                  validator: (v) => _validateShares(v, loc),
                ),
                const SizedBox(height: 20),

                // Optional passphrase
                _PassphraseField(controller: _passphraseCtrl),
                const SizedBox(height: 20),

                // BIP39 compatibility warnings
                ...bip39supported,
                if (bip39supported.isNotEmpty) const SizedBox(height: 20),

                // Generate button
                _GenerateButton(
                  label: loc.confirm,
                  onPressed: _generateShares,
                ),
                const SizedBox(height: 20),

                // Generated shares list
                ValueListenableBuilder<List<String>>(
                  valueListenable: _sharesList,
                  builder: (_, shares, __) => shares.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            ...shares.map(
                              (share) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _ShareField(
                                  share: share,
                                  copiedLabel: loc.copiedToClipboard,
                                ),
                              ),
                            ),
                            _RecoveryWarning(
                              recoveryMessage: loc.recoverWithNofYShares(
                                _thresholdCtrl.text,
                                _sharesCtrl.text,
                              ),
                              warningMessage: loc.neverShareYourShamirSecrets,
                            ),
                          ],
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

// ── Components ────────────────────────────────────────────────────────────────

/// Optional passphrase field used with SLIP39.
class _PassphraseField extends StatelessWidget {
  final TextEditingController controller;

  const _PassphraseField({required this.controller});

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Passphrase (optional)',
        filled: true,
        border: _border,
        focusedBorder: _border,
        enabledBorder: _border,
        prefixIcon: Icon(Icons.lock_outline),
      ),
    );
  }
}

/// Digits-only text field used for threshold and shares count.
class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String> validator;

  const _NumberField({
    required this.controller,
    required this.hint,
    required this.validator,
  });

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        border: _border,
        focusedBorder: _border,
        enabledBorder: _border,
      ),
    );
  }
}

/// Full-width generate / confirm button.
class _GenerateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GenerateButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: appBackgroundblue,
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

/// Read-only field displaying a single share with a copy icon.
class _ShareField extends StatelessWidget {
  final String share;
  final String copiedLabel;

  const _ShareField({required this.share, required this.copiedLabel});

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  );

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: share));
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(copiedLabel),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: share),
      decoration: InputDecoration(
        filled: true,
        border: _border,
        focusedBorder: _border,
        enabledBorder: _border,
        suffixIcon: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copy(context),
        ),
      ),
    );
  }
}

/// Red warning box shown after shares are generated.
class _RecoveryWarning extends StatelessWidget {
  final String recoveryMessage;
  final String warningMessage;

  const _RecoveryWarning({
    required this.recoveryMessage,
    required this.warningMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Text(
            recoveryMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            warningMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}