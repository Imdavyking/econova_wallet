// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/components/wallet_logo.dart';
import 'package:wallet_app/components/mnemonic_text_field.dart';
import 'package:wallet_app/modals/dialog_utils.dart';
import 'package:wallet_app/screens/import_shamir_secret.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:wallet_app/service/wallet_import_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/qr_scan_view.dart';
import 'package:wallet_app/main.dart';
import 'package:pinput/pinput.dart';

class EnterPhrase extends StatefulWidget {
  const EnterPhrase({super.key});

  @override
  State<EnterPhrase> createState() => _EnterPhraseState();
}

class _EnterPhraseState extends State<EnterPhrase> with WidgetsBindingObserver {
  // ── Controllers ────────────────────────────────────────────────────────────
  final _mnemonicController = TextEditingController();
  final _walletNameController = TextEditingController();

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _obscureMnemonic = false;
  bool _securityOverlayVisible = false;
  final _suggestions = ValueNotifier<List<String>>([]);

  late AppLocalizations _loc;
  final _screenshotCallback = ScreenshotCallback();
  String info = 'Seed phrase/BIP39 seed hex';

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    disEnableScreenShot();

    _screenshotCallback.addListener(_onScreenshot);

    if (kDebugMode) {
      _mnemonicController.text = testMnemonic1;
      _walletNameController.text = 'Test Wallet (DO NOT USE)';
    }
  }

  void _onScreenshot() => showDialogWithMessage(
        context: context,
        message: _loc.youCantScreenshot,
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        if (!_securityOverlayVisible) {
          setState(() {
            _obscureMnemonic = true;
            _securityOverlayVisible = true;
          });
        }
      case AppLifecycleState.resumed:
        if (_obscureMnemonic) _handleResume();
      default:
        break;
    }
  }

  Future<void> _handleResume() async {
    final authenticated = await authenticate(context);
    if (!mounted) return;
    if (authenticated) {
      await disEnableScreenShot();
      setState(() {
        _obscureMnemonic = false;
        _securityOverlayVisible = false;
      });
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    enableScreenShot();
    _screenshotCallback.dispose();
    _mnemonicController.dispose();
    _walletNameController.dispose();
    _suggestions.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onScanQr() async {
    final seedPhrase = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScanView()),
    );
    if (seedPhrase != null) _mnemonicController.setText(seedPhrase);
  }

  Future<void> _onImportShamir() async {
    final mnemonics = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ImportShamirSecret()),
    );
    if (mnemonics != null) _mnemonicController.setText(mnemonics);
  }

  Future<void> _onConfirm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final mnemonics = _mnemonicController.text.trim().toLowerCase();
    final walletName = _walletNameController.text.trim();

    if (walletName.isEmpty || mnemonics.isEmpty) {
      _showError(_loc.enterName);
      return;
    }

    setState(() => _isLoading = true);

    final result = await WalletImportService.importFromMnemonic(
      mnemonicOrBip39SeedHex: mnemonics,
      walletName: walletName,
    );

    if (!mounted) return;

    if (!result.success) {
      _showError(_errorMessage(result.error!));
      setState(() => _isLoading = false);
      return;
    }

    await pref.put(currentUserWalletNameKey, walletName);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Wallet()),
        (_) => false,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _errorMessage(WalletImportError error) => switch (error) {
        WalletImportError.invalidMnemonic => _loc.invalidmnemonic,
        WalletImportError.duplicate => _loc.mnemonicAlreadyImported,
        WalletImportError.unknown => _loc.errorTryAgain,
      };

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(info),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _onScanQr,
          ),
        ],
      ),
      body: _securityOverlayVisible
          ? const SizedBox.expand() // blank screen while locked
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WalletLogo(),
                    const SizedBox(height: 20),

                    // Wallet name
                    _NameField(controller: _walletNameController, loc: _loc),
                    const SizedBox(height: 20),

                    // Mnemonic input
                    MnemonicTextField(
                      controller: _mnemonicController,
                      hintText: info,
                      obscure: _obscureMnemonic,
                      onSuggestionsChanged: (s) => _suggestions.value = s,
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<List<String>>(
                      valueListenable: _suggestions,
                      builder: (_, suggestions, __) => MnemonicSuggestionsRow(
                        suggestions: suggestions,
                        controller: _mnemonicController,
                        onSelected: () => _suggestions.value = [],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ConfirmButton(
                      isLoading: _isLoading,
                      label: _loc.confirm,
                      onPressed: _isLoading ? null : _onConfirm,
                    ),
                    const SizedBox(height: 20),
                    // Shamir secret import
                    _OutlineButton(
                      label: _loc.importShamirSecret,
                      onPressed: _onImportShamir,
                    ),
                    const SizedBox(height: 20),

                    // Confirm

                    // Autocomplete suggestions
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Local sub-widgets ─────────────────────────────────────────────────────────

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations loc;

  const _NameField({required this.controller, required this.loc});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        hintText: loc.name,
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: appBackgroundblue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(15),
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
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  const _ConfirmButton({
    required this.isLoading,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: appBackgroundblue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(15),
      ),
      onPressed: onPressed,
      child: isLoading
          ? const Loader(color: Colors.black)
          : Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
