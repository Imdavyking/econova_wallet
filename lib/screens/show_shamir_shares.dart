// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:slip39/slip39.dart';

import 'package:wallet_app/ntcdcrypto.dart';
import 'package:wallet_app/utils/app_config.dart';

// Shared enum – move to a common file if both screens are in the same package.
enum ShamirScheme { sss, slip39 }

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
  final _isBase64 = ValueNotifier<bool>(true);
  final _scheme = ValueNotifier<ShamirScheme>(ShamirScheme.sss);

  static const _maxShares = 8;
  static const _minShares = 2;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Clear generated shares whenever the scheme changes so stale results
    // from the previous scheme are never shown.
    _scheme.addListener(() => _sharesList.value = []);
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    _sharesCtrl.dispose();
    _passphraseCtrl.dispose();
    _sharesList.dispose();
    _isBase64.dispose();
    _scheme.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────────────────────

  void _generateShares() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final minimum = int.parse(_thresholdCtrl.text.trim());
    final shares = int.parse(_sharesCtrl.text.trim());

    if (_scheme.value == ShamirScheme.sss) {
      _sharesList.value =
          SSS().create(minimum, shares, widget.data, _isBase64.value);
    } else {
      // SLIP39 requires an even-length byte array.
      var bytes = Uint8List.fromList(utf8.encode(widget.data));
      if (bytes.length.isOdd) {
        bytes = Uint8List.fromList([...bytes, 0]); // pad with a null byte
      }
      final slip = Slip39.from(
        [
          [minimum, shares]
        ],
        masterSecret: bytes,
        passphrase: _passphraseCtrl.text,
        threshold: 1,
      );
      _sharesList.value = slip.fromPath('r/0').mnemonics;
    }
  }

  String? _validateThreshold(String? v, AppLocalizations loc) {
    if (v == null || v.trim().isEmpty) return loc.enterValidthresholdCount;
    final threshold = int.tryParse(v);
    if (threshold == null || threshold <= 0)
      return loc.enterValidthresholdCount;
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
      appBar: AppBar(title: Text(loc.exportAsShamirShares)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: ValueListenableBuilder<ShamirScheme>(
              valueListenable: _scheme,
              builder: (_, scheme, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scheme selector
                  _SchemeToggle(notifier: _scheme),
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

                  // SSS-only: Base64 / Hex toggle
                  if (scheme == ShamirScheme.sss) ...[
                    _Base64Toggle(notifier: _isBase64, label: loc.isBase64),
                    const SizedBox(height: 20),
                  ],

                  // SLIP39-only: optional passphrase
                  if (scheme == ShamirScheme.slip39) ...[
                    _PassphraseField(controller: _passphraseCtrl),
                    const SizedBox(height: 20),
                  ],

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
                                threshold: _thresholdCtrl.text,
                                total: _sharesCtrl.text,
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
      ),
    );
  }
}

// ── Components ────────────────────────────────────────────────────────────────

/// Segmented control to switch between SSS and SLIP39 schemes.
class _SchemeToggle extends StatelessWidget {
  final ValueNotifier<ShamirScheme> notifier;

  const _SchemeToggle({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ShamirScheme>(
      valueListenable: notifier,
      builder: (_, scheme, __) => SegmentedButton<ShamirScheme>(
        segments: const [
          ButtonSegment(
            value: ShamirScheme.sss,
            label: Text('SSS'),
            icon: Icon(Icons.grid_view_rounded),
          ),
          ButtonSegment(
            value: ShamirScheme.slip39,
            label: Text('SLIP39'),
            icon: Icon(Icons.vpn_key_rounded),
          ),
        ],
        selected: {scheme},
        onSelectionChanged: (s) => notifier.value = s.first,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? appBackgroundblue
                : null,
          ),
        ),
      ),
    );
  }
}

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

/// Labelled Cupertino switch for the Base64 / Hex toggle (SSS only).
class _Base64Toggle extends StatelessWidget {
  final ValueNotifier<bool> notifier;
  final String label;

  const _Base64Toggle({required this.notifier, required this.label});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (_, value, __) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          CupertinoSwitch(
            value: value,
            activeColor: appBackgroundblue,
            onChanged: (_) => notifier.value = !notifier.value,
          ),
        ],
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
  final String threshold;
  final String total;
  final String recoveryMessage;
  final String warningMessage;

  const _RecoveryWarning({
    required this.threshold,
    required this.total,
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
