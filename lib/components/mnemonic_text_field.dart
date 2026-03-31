import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_app/main.dart';
import 'package:pinput/pinput.dart';

/// A mnemonic text input field with:
/// - BIP-39 word autocomplete suggestions
/// - Paste button overlay
/// - Optional obscure toggle (for security on pause)
class MnemonicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final ValueChanged<List<String>> onSuggestionsChanged;

  const MnemonicTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSuggestionsChanged,
    this.obscure = false,
  });

  void _onChanged(String val) {
    if (obscure) return;
    final words = val.toLowerCase().split(' ');
    final last = words.last.trim();
    if (last.isEmpty) {
      onSuggestionsChanged([]);
      return;
    }
    onSuggestionsChanged(
      mnemonicSuggester.autoComplete(prefix: last, limit: 15),
    );
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;
    controller.setText(data!.text!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: controller,
          maxLines: 3,
          obscureText: obscure,
          onChanged: _onChanged,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.only(
              top: 50,
              left: 12,
              right: 12,
              bottom: 12,
            ),
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
        ),
        if (!obscure)
          Positioned(
            right: 10,
            top: 10,
            child: _PasteButton(onTap: _paste),
          ),
      ],
    );
  }
}

class _PasteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PasteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'Paste',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

/// Row of tappable autocomplete suggestion chips.
class MnemonicSuggestionsRow extends StatelessWidget {
  final List<String> suggestions;
  final TextEditingController controller;
  final VoidCallback onSelected;

  const MnemonicSuggestionsRow({
    super.key,
    required this.suggestions,
    required this.controller,
    required this.onSelected,
  });

  void _selectWord(String word) {
    final current = controller.text;
    final lastSpace = current.lastIndexOf(' ');
    final prefix = lastSpace == -1 ? '' : current.substring(0, lastSpace);
    controller.setText('${prefix.isEmpty ? '' : '$prefix '}$word ');
    onSelected();
  }

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: suggestions
          .map(
            (w) => GestureDetector(
              onTap: () => _selectWord(w),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(w, style: const TextStyle(fontSize: 15)),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
