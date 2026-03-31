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

class _ShowShamirSharesState extends State<ShowShamirShares>
    with SingleTickerProviderStateMixin {
  // ── Controllers & state ────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _thresholdCtrl = TextEditingController();
  final _sharesCtrl = TextEditingController();
  final _passphraseCtrl = TextEditingController();
  final _sharesList = ValueNotifier<List<String>>([]);
  Map<String, Uint8List> cacheSeed = {};
  List<({String name, String symbol})> unsupportedChains = [];
  static const _maxShares = 8;
  static const _minShares = 2;
  bool validSeedPhrase = false;
  bool _isGenerating = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  Future<void> _checkValidSeed() async {
    validSeedPhrase = await compute(validateMnemonic, widget.data);
    if (mounted) setState(() {});
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    unsupportedChains = getChains()
        .where((e) => !e.supportBip39Seed && e.tokenAddress() == null)
        .map((e) => (name: e.getName(), symbol: e.getSymbol()))
        .toList();

    _checkValidSeed();
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    _sharesCtrl.dispose();
    _passphraseCtrl.dispose();
    _sharesList.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────────────────────

  void _generateShares() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isGenerating = true);

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
    _fadeCtrl.forward(from: 0);
    if (mounted) setState(() => _isGenerating = false);
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: isDark ? Colors.white70 : Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SLIP‑39',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Secret Sharing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── BIP39 Compatibility Warnings ───────────────────────────
                if (unsupportedChains.isNotEmpty) ...[
                  _Bip39WarningPanel(chains: unsupportedChains),
                  const SizedBox(height: 20),
                ],

                // ── Configuration Card ─────────────────────────────────────
                _SectionCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(text: 'Configuration', isDark: isDark),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _NumberField(
                              controller: _thresholdCtrl,
                              hint: loc.thresholdCount,
                              icon: Icons.key_rounded,
                              validator: (v) => _validateThreshold(v, loc),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _NumberField(
                              controller: _sharesCtrl,
                              hint: loc.sharesCount,
                              icon: Icons.call_split_rounded,
                              validator: (v) => _validateShares(v, loc),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _PassphraseField(
                          controller: _passphraseCtrl, isDark: isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Generate button ────────────────────────────────────────
                _GenerateButton(
                  label: loc.confirm,
                  isLoading: _isGenerating,
                  onPressed: _generateShares,
                ),
                const SizedBox(height: 24),

                // ── Generated Shares ───────────────────────────────────────
                ValueListenableBuilder<List<String>>(
                  valueListenable: _sharesList,
                  builder: (_, shares, __) {
                    if (shares.isEmpty) return const SizedBox.shrink();
                    return FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(
                              text: 'Generated Shares', isDark: isDark),
                          const SizedBox(height: 12),
                          ...shares.asMap().entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ShareCard(
                                    index: e.key + 1,
                                    share: e.value,
                                    copiedLabel: loc.copiedToClipboard,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                          const SizedBox(height: 8),
                          _RecoveryWarning(
                            recoveryMessage: loc.recoverWithNofYShares(
                              _thresholdCtrl.text,
                              _sharesCtrl.text,
                            ),
                            warningMessage: loc.neverShareYourShamirSecrets,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── BIP39 Warning Panel ────────────────────────────────────────────────────────

class _Bip39WarningPanel extends StatefulWidget {
  final List<({String name, String symbol})> chains;

  const _Bip39WarningPanel({required this.chains});

  @override
  State<_Bip39WarningPanel> createState() => _Bip39WarningPanelState();
}

class _Bip39WarningPanelState extends State<_Bip39WarningPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasMany = widget.chains.length > 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBEB), Color(0xFFFFF7E0)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBBF24).withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          GestureDetector(
            onTap:
                hasMany ? () => setState(() => _expanded = !_expanded) : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BIP‑39 Compatibility',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.chains.length == 1
                              ? '${widget.chains.first.name} may not recover correctly'
                              : '${widget.chains.length} chains may not recover correctly',
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand chevron (only when multiple chains)
                  if (hasMany)
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFFD97706),
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Chain list (always shown when single; expandable otherwise) ─
          if (!hasMany || _expanded) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: widget.chains.asMap().entries.map((entry) {
                  final isLast = entry.key == widget.chains.length - 1;
                  final chain = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        child: Row(
                          children: [
                            // Symbol pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                chain.symbol,
                                style: const TextStyle(
                                  color: Color(0xFF92400E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                chain.name,
                                style: const TextStyle(
                                  color: Color(0xFF78350F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 15,
                              color: Color(0xFFD97706),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          indent: 14,
                          endIndent: 14,
                          color: const Color(0xFFFBBF24).withOpacity(0.4),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),

            // ── Footer note ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 14, color: Color(0xFFD97706)),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Address recovery may not work for these chains. '
                      'Verify access before relying on these shares.',
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _SectionCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionLabel({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _PassphraseField extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;

  const _PassphraseField({required this.controller, required this.isDark});

  @override
  State<_PassphraseField> createState() => _PassphraseFieldState();
}

class _PassphraseFieldState extends State<_PassphraseField> {
  bool _visible = false;

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: widget.isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_visible,
      style: TextStyle(
          color: widget.isDark ? Colors.white : Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Passphrase (optional)',
        hintStyle: TextStyle(
            color: widget.isDark ? Colors.white30 : Colors.black38,
            fontSize: 14),
        filled: true,
        fillColor: widget.isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        border: _border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        enabledBorder: _border,
        prefixIcon: Icon(Icons.lock_outline_rounded,
            size: 18, color: widget.isDark ? Colors.white30 : Colors.black38),
        suffixIcon: IconButton(
          icon: Icon(
            _visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: widget.isDark ? Colors.white30 : Colors.black38,
          ),
          onPressed: () => setState(() => _visible = !_visible),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final bool isDark;

  const _NumberField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.isDark,
  });

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: isDark ? Colors.white30 : Colors.black38,
            fontSize: 13,
            fontWeight: FontWeight.w400),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        border: _border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        enabledBorder: _border,
        prefixIcon: Icon(icon,
            size: 18, color: isDark ? Colors.white30 : Colors.black38),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const _GenerateButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.generating_tokens_rounded,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ShareCard extends StatefulWidget {
  final int index;
  final String share;
  final String copiedLabel;
  final bool isDark;

  const _ShareCard({
    required this.index,
    required this.share,
    required this.copiedLabel,
    required this.isDark,
  });

  @override
  State<_ShareCard> createState() => _ShareCardState();
}

class _ShareCardState extends State<_ShareCard> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.share));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _copied
              ? const Color(0xFF22C55E).withOpacity(0.5)
              : (widget.isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.07)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Share ${widget.index}',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Copy button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _copied
                      ? Container(
                          key: const ValueKey('copied'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  size: 14, color: Color(0xFF22C55E)),
                              SizedBox(width: 4),
                              Text(
                                'Copied',
                                style: TextStyle(
                                    color: Color(0xFF22C55E),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : IconButton(
                          key: const ValueKey('copy'),
                          icon: Icon(
                            Icons.copy_rounded,
                            size: 17,
                            color:
                                widget.isDark ? Colors.white38 : Colors.black38,
                          ),
                          onPressed: _copy,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: widget.isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
          ),

          // Share text
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Text(
              widget.share,
              style: TextStyle(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.55)
                    : Colors.black54,
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.55,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Shield icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.shield_outlined, color: Colors.red, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            recoveryMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            warningMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
