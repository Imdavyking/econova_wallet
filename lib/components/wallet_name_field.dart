import 'package:flutter/material.dart';
import 'package:wallet_app/service/wallet_service.dart';

/// A name input field that validates uniqueness across ALL wallet types
/// (seed phrase, private key, view-only) in real time.
///
/// Usage:
/// ```dart
/// final _nameCtrl = TextEditingController();
/// final _nameKey  = GlobalKey<WalletNameFieldState>();
///
/// WalletNameField(controller: _nameCtrl, key: _nameKey)
///
/// // Before submitting:
/// if (!_nameKey.currentState!.isValid) return;
/// ```
class WalletNameField extends StatefulWidget {
  final TextEditingController controller;

  /// Optional: wallet being *renamed*. Its current name is excluded from the
  /// duplicate check so a user can re-save the same name without an error.
  final WalletParams? editingWallet;

  const WalletNameField({
    super.key,
    required this.controller,
    this.editingWallet,
  });

  @override
  State<WalletNameField> createState() => WalletNameFieldState();
}

class WalletNameFieldState extends State<WalletNameField> {
  String? _errorText;

  /// True when the field contains a non-empty, unique name.
  bool get isValid =>
      _errorText == null && widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    final name = widget.controller.text.trim();
    String? error;

    if (name.isEmpty) {
      error = null; // show nothing while empty; submit handler shows the error
    } else {
      final isSelf = widget.editingWallet != null &&
          widget.editingWallet!.name.toLowerCase().trim() ==
              name.toLowerCase().trim();

      if (!isSelf && WalletService.doesNameExist(name)) {
        error = 'A wallet named "$name" already exists';
      }
    }

    if (error != _errorText) setState(() => _errorText = error);
  }

  /// Call from the submit handler to trigger visible validation even if the
  /// user never typed (e.g. submitted an empty field immediately).
  bool validateOnSubmit() {
    final name = widget.controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Please enter a wallet name');
      return false;
    }
    _validate();
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Wallet name',
        errorText: _errorText,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
        errorBorder: _errorBorder,
        focusedErrorBorder: _errorBorder,
        filled: true,
      ),
    );
  }
}

const _border = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  borderSide: BorderSide.none,
);

const _errorBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  borderSide: BorderSide(color: Colors.red, width: 1),
);
