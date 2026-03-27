// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/components/mnemonic_step_indicator.dart';
import 'package:wallet_app/components/mnemonic_word_grid.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/modals/dialog_utils.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:wallet_app/service/wallet_import_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';

// ── Constants ────────────────────────────────────────────────────────────────

const _totalSteps = 4;
const _wordsPerStep = 3;

// Words 1–12 split into four groups of three (1-indexed)
const _stepWords = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9],
  [10, 11, 12],
];

// ── Widget ───────────────────────────────────────────────────────────────────

class ConfirmMnemonic extends StatefulWidget {
  final List<String> mnemonic;

  const ConfirmMnemonic({super.key, required this.mnemonic});

  @override
  _ConfirmMnemonicState createState() => _ConfirmMnemonicState();
}

class _ConfirmMnemonicState extends State<ConfirmMnemonic> {
  // ── State ──────────────────────────────────────────────────────────────────
  late List<String> _shuffled;
  final Set<int> _confirmedIndexes = {};

  int _step = 0; // 0–3 (which group of 3 we're verifying)
  int _confirmedInStep = 0; // how many words correct so far in this step (0–3)
  bool _allDone = false;
  bool _isLoading = false;

  late AppLocalizations _loc;
  final _screenshotCallback = ScreenshotCallback();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _shuffle();
    disEnableScreenShot();
    _screenshotCallback.addListener(_onScreenshot);
  }

  void _shuffle() {
    _shuffled = [...widget.mnemonic]..shuffle();
  }

  void _onScreenshot() => showDialogWithMessage(
        context: context,
        message: _loc.youCantScreenshot,
      );

  @override
  void dispose() {
    _screenshotCallback.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────────────────────

  List<int> get _currentTargetWords => _stepWords[_step];

  void _onWordTapped(int index) {
    final expected = widget.mnemonic[_currentTargetWords[_confirmedInStep] - 1];
    if (_shuffled[index] != expected) {
      _onWrongWord();
      return;
    }

    setState(() {
      _confirmedIndexes.add(index);
      _confirmedInStep++;

      if (_confirmedInStep == _wordsPerStep) {
        _confirmedInStep = 0;
        if (_step == _totalSteps - 1) {
          _allDone = true;
        } else {
          _step++;
        }
      }
    });
  }

  void _onWrongWord() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            _loc.invalidmnemonic,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    setState(() {
      _shuffled = [];
      _confirmedIndexes.clear();
      _step = 0;
      _confirmedInStep = 0;
      _allDone = false;
    });
    // Defer shuffle so widget rebuilds with empty list first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(_shuffle);
    });
  }

  Future<void> _onContinue() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final mnemonics = widget.mnemonic.join(' ');
    final walletList = WalletImportService.getNextWalletName();

    final result = await WalletImportService.importFromMnemonic(
      mnemonics: mnemonics,
      walletName: walletList,
    );

    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            _errorMessage(result.error!),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    await pref.put(currentUserWalletNameKey, null);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Wallet()),
        (_) => false,
      );
    }
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
      appBar: AppBar(title: Text(_loc.confirmmnemonic)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_allDone) ...[
                MnemonicStepIndicator(
                  wordNumbers: _currentTargetWords,
                  wordValues: widget.mnemonic,
                  confirmedCount: _confirmedInStep,
                ),
                const SizedBox(height: 8),
                _StepProgress(current: _step, total: _totalSteps),
                const SizedBox(height: 4),
              ],
              MnemonicWordGrid(
                words: _shuffled,
                confirmedIndexes: _confirmedIndexes,
                onTap: _allDone ? (_) {} : _onWordTapped,
              ),
              const SizedBox(height: 40),
              _ContinueButton(
                enabled: _allDone && !_isLoading,
                isLoading: _isLoading,
                label: _loc.continue_,
                onPressed: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Local sub-widgets ─────────────────────────────────────────────────────────

class _StepProgress extends StatelessWidget {
  final int current;
  final int total;

  const _StepProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final done = i <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            decoration: BoxDecoration(
              color: done
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _ContinueButton({
    required this.enabled,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(15),
        ),
        onPressed: enabled ? onPressed : null,
        child: isLoading
            ? const Loader(color: Colors.black)
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
