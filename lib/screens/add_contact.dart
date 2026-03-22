import 'package:wallet_app/modals/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../service/contact_service.dart';
import '../utils/app_config.dart';
import '../utils/qr_scan_view.dart';

class AddContact extends StatefulWidget {
  final ContactParams params;
  const AddContact({super.key, required this.params});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _memoCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.params.name);
    _addressCtrl = TextEditingController(text: widget.params.address);
    _memoCtrl = TextEditingController(text: widget.params.memo ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  /// Returns an error string or null if valid.
  String? _validate() {
    final name = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    if (name.isEmpty || address.isEmpty) {
      return AppLocalizations.of(context)!.enterNameAndAddress;
    }

    if (!RegExp(r'^[a-zA-Z0-9_ ]+$').hasMatch(name)) {
      return AppLocalizations.of(context)!.validContactName;
    }

    try {
      widget.params.coin.validateAddress(address);
    } catch (_) {
      return AppLocalizations.of(context)!.invalidAddress;
    }

    return null;
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => _saving = true);

    try {
      final updated = widget.params.copyWith(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        memo: _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim(),
      );

      final contacts = await ContactService.saveContact(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.done)),
      );
      Navigator.pop(context, contacts);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ));
  }

  // ── Back guard ────────────────────────────────────────────────────────────

  Future<bool> _onWillPop() async {
    bool willPop = false;
    await showDialogWithMessage(
      context: context,
      btnCancelColor: Colors.blue,
      btnOkColor: Colors.red[400]!,
      message: AppLocalizations.of(context)!.confirmClose,
      onConfirm: () => willPop = true,
      onCancel: () => willPop = false,
    );
    return willPop;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final requiresMemo = widget.params.coin.requireMemo();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final willPop = await _onWillPop();
        if (willPop && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.params.coin.getName()} Contact'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoundedTextField(
                    controller: _nameCtrl,
                    hint: localization.name,
                  ),
                  const SizedBox(height: 20),
                  _RoundedTextField(
                    controller: _addressCtrl,
                    hint: localization.address,
                    suffix: _InputSuffix(
                      controller: _addressCtrl,
                      pasteLabel: localization.paste,
                    ),
                  ),
                  if (requiresMemo) ...[
                    const SizedBox(height: 20),
                    _RoundedTextField(
                      controller: _memoCtrl,
                      hint: localization.memo,
                      suffix: _InputSuffix(
                        controller: _memoCtrl,
                        pasteLabel: localization.paste,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _SaveButton(
                    label: localization.save,
                    loading: _saving,
                    onPressed: _save,
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

// ── Reusable rounded text field ───────────────────────────────────────────────

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? suffix;

  const _RoundedTextField({
    required this.controller,
    required this.hint,
    this.suffix,
  });

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        focusedBorder: _border,
        border: _border,
        enabledBorder: _border,
        filled: true,
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

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    controller.setText(text);
  }

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
            if (result == null) return;
            controller.setText(result);
          },
        ),
        InkWell(
          onTap: _paste,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(pasteLabel),
          ),
        ),
      ],
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
