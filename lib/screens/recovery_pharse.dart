// ignore_for_file: library_private_types_in_public_api

import 'package:bip39/bip39.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:wallet_app/modals/dialog_utils.dart';
import 'package:wallet_app/screens/confirm_seed_phrase.dart';
import 'package:wallet_app/screens/show_shamir_shares.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';

class RecoveryPhrase extends StatefulWidget {
  final String data;
  final bool viewOnly;

  const RecoveryPhrase({
    super.key,
    required this.data,
    this.viewOnly = true,
  });

  @override
  _RecoveryPhraseState createState() => _RecoveryPhraseState();
}

class _RecoveryPhraseState extends State<RecoveryPhrase>
    with WidgetsBindingObserver {
  bool _obscured = false;
  bool _securityOverlayVisible = false;

  bool validSeedPhrase = false;

  late AppLocalizations _loc;
  final _screenshotCallback = ScreenshotCallback();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    disEnableScreenShot();
    _screenshotCallback.addListener(
      () => showDialogWithMessage(
        context: context,
        message: _loc.youCantScreenshot,
      ),
    );
    _checkValidSeed();
  }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        if (!_securityOverlayVisible) {
          setState(() {
            _obscured = true;
            _securityOverlayVisible = true;
          });
        }
      case AppLifecycleState.resumed:
        if (_obscured) _handleResume();
      default:
        break;
    }
  }

  Future<void> _handleResume() async {
    final ok = await authenticate(context);
    if (!mounted) return;
    if (ok) {
      await disEnableScreenShot();
      setState(() {
        _obscured = false;
        _securityOverlayVisible = false;
      });
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenshotCallback.dispose();
    enableScreenShot();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_loc.copiedToClipboard)),
    );
  }

  void _goToShamirShares() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShowShamirShares(data: widget.data),
        ),
      );

  void _goToConfirmMnemonic() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmMnemonic(mnemonic: widget.data.split(' ')),
        ),
      );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(_loc.yourSecretPhrase)),
      body: _securityOverlayVisible
          ? const SizedBox.expand()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Text(
                      _loc.writeDownYourmnemonic,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    if (validSeedPhrase)
                      _MnemonicGrid(words: widget.data.split(' '))
                    else
                      // Word grid
                      Text(widget.data),
                    const SizedBox(height: 15),

                    // Copy button (setup flow only)
                    if (!widget.viewOnly) ...[
                      _CopyButton(
                        label: _loc.copy,
                        onTap: _copyToClipboard,
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Warning banner
                    _WarningBanner(
                      title: _loc.doNotShareYourmnemonic,
                      body: _loc.ifSomeoneHasYourmnemonic,
                    ),
                    const SizedBox(height: 40),

                    // Action buttons
                    if (widget.viewOnly)
                      _ActionButton(
                        label: _loc.exportAsShamirShares,
                        onPressed: _goToShamirShares,
                      )
                    else if (validSeedPhrase)
                      _ActionButton(
                        label: _loc.continue_,
                        onPressed: _goToConfirmMnemonic,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Components ────────────────────────────────────────────────────────────────

/// Renders the mnemonic words in a 3-column numbered grid.
class _MnemonicGrid extends StatelessWidget {
  final List<String> words;

  const _MnemonicGrid({required this.words});

  @override
  Widget build(BuildContext context) {
    final rows = words.length ~/ 3;

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: List.generate(3, (col) {
              final index = row * 3 + col;
              return Expanded(
                child: _WordCard(number: index + 1, word: words[index]),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _WordCard extends StatelessWidget {
  final int number;
  final String word;

  const _WordCard({required this.number, required this.word});

  @override
  Widget build(BuildContext context) {
    final bodyColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text.rich(
          TextSpan(
            text: '$number. ',
            style: const TextStyle(color: Colors.grey),
            children: [
              TextSpan(text: word, style: TextStyle(color: bodyColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CopyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              const Icon(Icons.copy, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String title;
  final String body;

  const _WarningBanner({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.onPressed});

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
