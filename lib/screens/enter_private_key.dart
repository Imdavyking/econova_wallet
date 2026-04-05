import 'package:bs58check/bs58check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:hex/hex.dart';
import 'package:pinput/pinput.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/interface/keystore.dart';
import 'package:wallet_app/modals/dialog_utils.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/get_token_image.dart';
import 'package:wallet_app/utils/is_hex_without_prefix.dart';
import 'package:wallet_app/utils/qr_scan_view.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:web3dart/crypto.dart';

import '../main.dart';

enum _ImportMode { privateKey, keystore }

class EnterPrivateKey extends StatefulWidget {
  final Coin coin;
  const EnterPrivateKey({super.key, required this.coin});

  @override
  State<EnterPrivateKey> createState() => _EnterPrivateKeyState();
}

class _EnterPrivateKeyState extends State<EnterPrivateKey>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────

  final _privateKeyCtrl = TextEditingController();
  final _keystoreCtrl = TextEditingController();
  final _walletNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late final TabController _tabCtrl;
  final _screenshotCallback = ScreenshotCallback();

  // ── State ──────────────────────────────────────────────────────────────────

  _ImportMode _mode = _ImportMode.privateKey;
  bool _isLoading = false;
  bool _isObscured = false;
  bool _securityDialogOpen = false;

  late AppLocalizations _loc;

  bool get _supportsKeystore => widget.coin.supportKeystore;
  TextEditingController get _activeCtrl =>
      _mode == _ImportMode.privateKey ? _privateKeyCtrl : _keystoreCtrl;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: _supportsKeystore ? 2 : 1,
      vsync: this,
    )..addListener(() {
        setState(() {
          _mode = _tabCtrl.index == 0
              ? _ImportMode.privateKey
              : _ImportMode.keystore;
        });
      });

    disEnableScreenShot();
    WidgetsBinding.instance.addObserver(this);
    _screenshotCallback.addListener(_onScreenshot);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _privateKeyCtrl.dispose();
    _keystoreCtrl.dispose();
    _walletNameCtrl.dispose();
    _passwordCtrl.dispose();
    _screenshotCallback.dispose();
    enableScreenShot();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && !_securityDialogOpen) {
      setState(() {
        _isObscured = true;
        _securityDialogOpen = true;
      });
    } else if (state == AppLifecycleState.resumed && _isObscured) {
      _isObscured = false;
      if (await authenticate(context)) {
        await disEnableScreenShot();
        setState(() => _securityDialogOpen = false);
      } else {
        SystemNavigator.pop();
      }
    }
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  void _onScreenshot() =>
      showDialogWithMessage(context: context, message: _loc.youCantScreenshot);

  Future<void> _onScanQr() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScanView()),
    );
    if (result != null) _activeCtrl.setText(result);
  }

  Future<void> _onPaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) _activeCtrl.setText(data!.text!);
  }

  Future<void> _onConfirm() async {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final walletName = _walletNameCtrl.text.trim();
    final privateKey = _privateKeyCtrl.text.trim();
    final keystore = _keystoreCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (!_validate(walletName, privateKey, keystore)) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final resolvedKey = _mode == _ImportMode.privateKey
          ? _resolvePrivateKey(privateKey)
          : await _resolveKeystore(keystore, password);

      final existing = WalletService.getActiveKeys(WalletType.privateKey);
      final entry = PrivateKeyParams(
        data: resolvedKey,
        name: walletName,
        defaultCoin: widget.coin.getDefault(),
        coinName: widget.coin.getName(),
      );

      if (existing.any((k) => k == entry)) {
        _showError(_loc.walletAlreadyImported);
        return;
      }

      await WalletService.setActiveKey(WalletType.privateKey, entry);
      await widget.coin.importData(resolvedKey);
      await pref.put(currentUserWalletNameKey, walletName);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Wallet()),
          (_) => false,
        );
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('$e\n$st');
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _validate(String walletName, String privateKey, String keystore) {
    if (walletName.isEmpty) return _showError(_loc.enterName);
    if (_mode == _ImportMode.privateKey && privateKey.isEmpty) {
      return _showError(_loc.enterPrivateKey);
    }
    if (_mode == _ImportMode.keystore && keystore.isEmpty) {
      return _showError(_loc.enterKeystore);
    }
    return true;
  }

  /// Returns false after showing error — used for early returns.
  bool _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ));
    return false;
  }

  String _resolvePrivateKey(String raw) {
    var key = strip0x(raw).split(':').last;

    // raw hex path
    if (isHEXstrip0x(key)) {
      final bytes = HEX.decode(key) as Uint8List;
      if (bytes.length != 32) throw Exception(_loc.invalidPrivateKey);
      return key;
    }

    final decoded = base58.decode(key);

    // Solana keypair: 64 bytes, private key is first 32
    if (decoded.length == 64) {
      return HEX.encode(decoded.sublist(0, 32));
    }

    // Bitcoin WIF: 33 bytes (uncompressed) or 34 bytes (compressed)
    // first byte is version byte 0x80, skip it
    if (decoded.length == 33 || decoded.length == 34) {
      if (decoded[0] != 0x80) throw Exception(_loc.invalidPrivateKey);
      return HEX.encode(decoded.sublist(1, 33));
    }

    throw Exception(_loc.invalidPrivateKey);
  }

  Future<String> _resolveKeystore(String keystore, String password) async {
    final bytes = await compute(
      KeyStore.fromKeystore,
      KeyStoreParams(keystore: keystore, password: password),
    );
    return HEX.encode(bytes);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _loc = AppLocalizations.of(context)!;

    if (_securityDialogOpen) return const Scaffold(body: SizedBox.shrink());

    return Scaffold(
      appBar: AppBar(
        title: Text('Restore ${widget.coin.getName()}'),
        actions: [
          IconButton(
            onPressed: _onScanQr,
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              GetTokenImage(currCoin: widget.coin, radius: 30),
              const SizedBox(height: 20),
              _NameField(controller: _walletNameCtrl),
              const SizedBox(height: 20),
              if (_supportsKeystore) ...[
                _ModeTabBar(controller: _tabCtrl),
                const SizedBox(height: 20),
              ],
              _InputField(
                controller: _activeCtrl,
                hint: _mode == _ImportMode.privateKey
                    ? _loc.enterPrivateKey
                    : _loc.enterKeystore,
                onPaste: _onPaste,
              ),
              const SizedBox(height: 20),
              if (_mode == _ImportMode.keystore) ...[
                _PasswordField(controller: _passwordCtrl),
                const SizedBox(height: 20),
              ],
              _ConfirmButton(
                isLoading: _isLoading,
                label: _loc.confirm,
                onPressed: _onConfirm,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.name,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
        filled: true,
      ),
    );
  }
}

class _ModeTabBar extends StatelessWidget {
  final TabController controller;
  const _ModeTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color.fromRGBO(0, 80, 209, 0.1),
      ),
      child: TabBar(
        controller: controller,
        splashBorderRadius: BorderRadius.circular(22),
        labelColor: Colors.black,
        unselectedLabelColor: appBackgroundblue,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: appBackgroundblue,
        ),
        tabs: const [
          Tab(text: 'Private Key'),
          Tab(text: 'KeyStore JSON'),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onPaste;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          maxLines: 3,
          controller: controller,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(top: 100, left: 12, right: 12),
            hintText: hint,
            border: _border,
            enabledBorder: _border,
            focusedBorder: _border,
            filled: true,
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: InkWell(
            onTap: onPaste,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(AppLocalizations.of(context)!.paste),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  const _PasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.enterPassword,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
        filled: true,
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _ConfirmButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: appBackgroundblue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(15),
        ),
        onPressed: isLoading ? null : onPressed,
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
      ),
    );
  }
}

const _border = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  borderSide: BorderSide.none,
);
