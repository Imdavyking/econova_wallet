import 'package:flutter/material.dart';

/// Displays the three target words for the current verification step.
/// Each card shows either the word number (pending) or the actual word
/// (confirmed), with a green highlight when confirmed.
class MnemonicStepIndicator extends StatelessWidget {
  final List<int> wordNumbers; // e.g. [1, 2, 3]
  final List<String> wordValues; // full mnemonic array
  final int confirmedCount; // how many have been tapped correctly (0–3)

  const MnemonicStepIndicator({
    super.key,
    required this.wordNumbers,
    required this.wordValues,
    required this.confirmedCount,
  }) : assert(wordNumbers.length == 3);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select each word in order',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(3, (i) {
                final confirmed = i < confirmedCount;
                return Expanded(
                  child: _StepCard(
                    label: confirmed
                        ? wordValues[wordNumbers[i] - 1]
                        : '${wordNumbers[i]}',
                    isConfirmed: confirmed,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String label;
  final bool isConfirmed;

  const _StepCard({required this.label, required this.isConfirmed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color:
            isConfirmed ? Colors.green.shade100 : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConfirmed ? Colors.green.shade400 : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isConfirmed ? Colors.green.shade800 : null,
            fontWeight: isConfirmed ? FontWeight.w600 : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
