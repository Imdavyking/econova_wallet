// ignore_for_file: library_private_types_in_public_api

import 'package:wallet_app/modals/dialog_utils.dart';
import 'package:wallet_app/screens/main_screen.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../main.dart';

class Security extends StatefulWidget {
  final bool? isEnterPin;
  final bool? isChangingPin;
  final bool? useLocalAuth;

  const Security({
    super.key,
    this.isEnterPin,
    this.isChangingPin,
    this.useLocalAuth,
  });

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  final _pinController = TextEditingController();
  final _pinController2 = TextEditingController();
  final _screenshotCallback = ScreenshotCallback();

  bool _isConfirming = false;
  late List<String> _numbers;
  int _currentTrial = 0;

  @override
  void initState() {
    super.initState();
    _numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']..shuffle();
    _screenshotCallback.addListener(() {
      showDialogWithMessage(
        context: context,
        message: localization.youCantScreenshot,
      );
    });
    disEnableScreenShot();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinController2.dispose();
    if (widget.isEnterPin != true) enableScreenShot();
    super.dispose();
  }

  TextEditingController get _currentController =>
      _isConfirming ? _pinController2 : _pinController;

  void _onPinCompleted(String _) async {
    FocusManager.instance.primaryFocus?.unfocus();

    // ── Enter mode (unlock / auth) ──────────────────────────────────────────
    if (widget.isEnterPin == true) {
      _currentTrial++;
      final correct =
          pref.get(userUnlockPasscodeKey) == _pinController.text.trim();
      final hasTrials = _currentTrial < userPinTrials;

      if (correct) {
        Navigator.pop(context, true);
      } else if (hasTrials) {
        _pinController.clear();
      } else {
        Navigator.pop(context, false);
      }
      return;
    }

    // ── Create mode — confirm step ──────────────────────────────────────────
    if (_isConfirming) {
      if (_pinController.text.trim() == _pinController2.text.trim()) {
        await pref.put(userUnlockPasscodeKey, _pinController2.text.trim());
        if (widget.isChangingPin == true) {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          return;
        }
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (_) => false,
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(localization.passcodeMismatch,
              style: const TextStyle(color: Colors.white)),
        ));
        _pinController.clear();
        _pinController2.clear();
        setState(() => _isConfirming = false);
      }
      return;
    }

    // ── Create mode — first entry done, move to confirm ─────────────────────
    setState(() => _isConfirming = true);
  }

  late AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    final trialsRemaining = userPinTrials - _currentTrial;

    final title = widget.isEnterPin == true
        ? localization.enterYourPasscode
        : _isConfirming
            ? localization.confirmYourPin
            : localization.createYourPin;

    return Scaffold(
      appBar: AppBar(title: Text(localization.security)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(45, 25, 45, 25),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .8,
              child: Column(
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Pinput(
                    defaultPinTheme: PinTheme(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: appBackgroundblue),
                      ),
                    ),
                    obscuringCharacter: ' ',
                    submittedPinTheme: const PinTheme(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appPrimaryColor,
                      ),
                    ),
                    cursor: Container(),
                    useNativeKeyboard: false,
                    onCompleted: _onPinCompleted,
                    length: pinLength,
                    onChanged: (_) => setState(() {}),
                    autofocus: true,
                    obscureText: true,
                    controller: _currentController,
                  ),
                  const SizedBox(height: 20),
                  if (widget.isChangingPin != true &&
                      trialsRemaining != userPinTrials)
                    Text(
                      localization.youHave(trialsRemaining),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 20),
                  // ── Number pad ──────────────────────────────────────────────
                  _NumRow(keys: [
                    _NumPadKey(
                        label: _numbers[0],
                        onTap: () => _currentController.text += _numbers[0]),
                    _NumPadKey(
                        label: _numbers[1],
                        onTap: () => _currentController.text += _numbers[1]),
                    _NumPadKey(
                        label: _numbers[2],
                        onTap: () => _currentController.text += _numbers[2]),
                  ]),
                  const SizedBox(height: 20),
                  _NumRow(keys: [
                    _NumPadKey(
                        label: _numbers[3],
                        onTap: () => _currentController.text += _numbers[3]),
                    _NumPadKey(
                        label: _numbers[4],
                        onTap: () => _currentController.text += _numbers[4]),
                    _NumPadKey(
                        label: _numbers[5],
                        onTap: () => _currentController.text += _numbers[5]),
                  ]),
                  const SizedBox(height: 20),
                  _NumRow(keys: [
                    _NumPadKey(
                        label: _numbers[6],
                        onTap: () => _currentController.text += _numbers[6]),
                    _NumPadKey(
                        label: _numbers[7],
                        onTap: () => _currentController.text += _numbers[7]),
                    _NumPadKey(
                        label: _numbers[8],
                        onTap: () => _currentController.text += _numbers[8]),
                  ]),
                  const SizedBox(height: 20),
                  _NumRow(keys: [
                    // Biometric or spacer
                    if (widget.isEnterPin == true &&
                        (widget.useLocalAuth ?? true))
                      _NumPadKey.icon(
                        icon: Icons.fingerprint,
                        onTap: () async {
                          final ok = await localAuthentication();
                          if (ok && context.mounted) {
                            Navigator.pop(context, ok);
                          }
                        },
                      )
                    else
                      const _NumPadKey.empty(),
                    _NumPadKey(
                        label: _numbers[9],
                        onTap: () => _currentController.text += _numbers[9]),
                    _NumPadKey.icon(
                      icon: Icons.backspace,
                      onTap: () {
                        final text = _currentController.text;
                        if (text.isEmpty) return;
                        _currentController
                            .setText(text.substring(0, text.length - 1));
                      },
                    ),
                  ]),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      localization.passcodeInfo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
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

// ── Numpad components ─────────────────────────────────────────────────────────

class _NumRow extends StatelessWidget {
  final List<Widget> keys;
  const _NumRow({required this.keys});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys,
      );
}

class _NumPadKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _NumPadKey({this.label, required this.onTap}) : icon = null;
  const _NumPadKey.icon({required this.icon, required this.onTap})
      : label = null;
  const _NumPadKey.empty()
      : label = null,
        icon = null,
        onTap = null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: label != null
              ? Text(label!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 25))
              : icon != null
                  ? Icon(icon!, size: 35)
                  : const SizedBox(),
        ),
      ),
    );
  }
}
