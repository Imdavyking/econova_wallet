// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:hex/hex.dart';
import 'package:slip39/slip39.dart';
import 'package:pinput/pinput.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/qr_scan_view.dart';
import 'package:wallet_app/utils/slip39.dart' as slip39utils;

class ImportShamirSecret extends StatefulWidget {
  const ImportShamirSecret({super.key});

  @override
  State<ImportShamirSecret> createState() => _ImportShamirSecretState();
}

class _ImportShamirSecretState extends State<ImportShamirSecret> {
  // ── State ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _shares = ValueNotifier<List<String>>(['']);
  final _passphraseCtrl = TextEditingController();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _shares.dispose();
    _passphraseCtrl.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────────────────────

  void _addShare() => _shares.value = [..._shares.value, ''];

  void _removeShare(int index) {
    final updated = [..._shares.value]..removeAt(index);
    _shares.value = updated;
  }

  void _updateShare(int index, String value) {
    final updated = [..._shares.value];
    updated[index] = value;
    _shares.value = updated;
  }

  void _combine() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      final sharesList = _shares.value.map((e) => e.trim()).toList();
      final setList = Set.from(sharesList);
      if (setList.length != sharesList.length) {
        throw Exception('A secret was duplicated');
      }

      final decoded = slip39utils.decodeMnemonics(sharesList);
      final minimumLen = decoded.groups.first.memberThreshold;

      if (sharesList.length < minimumLen) {
        throw Exception('At least $minimumLen shares needed');
      }

      final List<int> recovered = Slip39.recoverSecret(
        sharesList.sublist(0, minimumLen),
        passphrase: _passphraseCtrl.text.trim(),
      );
      final result = HEX.encode(recovered);

      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            dismissDirection: DismissDirection.up,
            content: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Import SLIP39 Shares')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Dynamic share fields
              Expanded(
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: _shares,
                  builder: (_, shares, __) => ListView.separated(
                    itemCount: shares.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final isLast = index == shares.length - 1;
                      return Row(
                        children: [
                          Expanded(
                            child: _ShareTextField(
                              key: ValueKey('share_$index'),
                              initialValue: shares[index],
                              onChanged: (v) => _updateShare(index, v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _AddRemoveButton(
                            isAdd: isLast,
                            onTap: isLast ? _addShare : () => _removeShare(index),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Passphrase field
              _PassphraseField(controller: _passphraseCtrl),
              const SizedBox(height: 12),

              // Confirm / combine button
              _ConfirmButton(label: loc.confirm, onPressed: _combine),
              const SizedBox(height: 20),
            ],
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

/// Single share input with QR scan and paste actions.
class _ShareTextField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const _ShareTextField({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<_ShareTextField> createState() => _ShareTextFieldState();
}

class _ShareTextFieldState extends State<_ShareTextField> {
  late final TextEditingController _controller;

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final share = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScanView()),
    );
    if (share == null) return;
    _controller.setText(share);
    widget.onChanged(share);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null) return;
    _controller.setText(text);
    widget.onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return TextFormField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLines: 4,
      minLines: 3,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Please enter a share' : null,
      decoration: InputDecoration(
        filled: true,
        hintText: 'Enter your SLIP39 share',
        border: _border,
        focusedBorder: _border,
        enabledBorder: _border,
        suffixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanQr,
                  tooltip: 'Scan QR',
                ),
                _PasteButton(label: loc.paste, onTap: _paste),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline paste text button used inside the share field suffix.
class _PasteButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PasteButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(label),
      ),
    );
  }
}

/// Circular add (green) / remove (red) button beside each share field.
class _AddRemoveButton extends StatelessWidget {
  final bool isAdd;
  final VoidCallback onTap;

  const _AddRemoveButton({required this.isAdd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAdd ? Colors.green : Colors.red,
        ),
        child: Icon(
          isAdd ? Icons.add : Icons.remove,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

/// Full-width confirm / combine button.
class _ConfirmButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ConfirmButton({required this.label, required this.onPressed});

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