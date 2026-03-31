import 'package:flutter/material.dart';

/// A 3-column grid of tappable word chips.
/// Tapped/confirmed words become greyed out.
class MnemonicWordGrid extends StatelessWidget {
  final List<String> words;
  final Set<int> confirmedIndexes;
  final void Function(int index) onTap;

  const MnemonicWordGrid({
    super.key,
    required this.words,
    required this.confirmedIndexes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const columns = 3;
    final rows = (words.length / columns).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: List.generate(columns, (col) {
              final idx = row * columns + col;
              if (idx >= words.length) return const Expanded(child: SizedBox());
              final used = confirmedIndexes.contains(idx);

              return Expanded(
                child: GestureDetector(
                  onTap: used ? null : () => onTap(idx),
                  child: _WordChip(word: words[idx], used: used),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool used;

  const _WordChip({required this.word, required this.used});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      opacity: used ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Card(
        color: used ? scheme.surfaceVariant : null,
        elevation: used ? 0 : 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            word,
            style: TextStyle(
              color: used ? scheme.onSurface.withOpacity(0.4) : null,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
