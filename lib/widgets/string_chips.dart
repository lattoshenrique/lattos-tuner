import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/note.dart';
import '../theme.dart';

/// Fileira de "pílulas" com as cordas do preset ativo.
///
/// A corda alvo ganha borda e brilho na cor do estado; tocar em uma corda a
/// trava como alvo manual (tocar de novo destrava); cordas já afinadas
/// exibem um check animado.
class StringChips extends StatelessWidget {
  const StringChips({
    super.key,
    required this.notes,
    required this.targetIndex,
    required this.lockedIndex,
    required this.tunedIndices,
    required this.accentColor,
    required this.onTap,
  });

  final List<String> notes;
  final int? targetIndex;
  final int? lockedIndex;
  final Set<int> tunedIndices;
  final Color accentColor;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < notes.length; i++)
          _StringChip(
            label: notes[i],
            isTarget: targetIndex == i,
            isLocked: lockedIndex == i,
            isTuned: tunedIndices.contains(i),
            accentColor: accentColor,
            onTap: () {
              HapticFeedback.selectionClick();
              onTap(i);
            },
          ),
      ],
    );
  }
}

class _StringChip extends StatelessWidget {
  const _StringChip({
    required this.label,
    required this.isTarget,
    required this.isLocked,
    required this.isTuned,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool isTarget;
  final bool isLocked;
  final bool isTuned;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = isTarget || isLocked;
    final borderColor = isLocked
        ? accentColor
        : isTarget
            ? accentColor.withValues(alpha: 0.7)
            : AppColors.outline;
    final noteColor = highlight
        ? accentColor
        : isTuned
            ? AppColors.mint.withValues(alpha: 0.9)
            : AppColors.textSecondary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isLocked
            ? accentColor.withValues(alpha: 0.16)
            : AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: highlight ? 1.6 : 1.0),
        boxShadow: [
          if (highlight)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: -2,
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocked) ...[
              Icon(Icons.push_pin_rounded, size: 14, color: accentColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: noteColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              child: isTuned
                  ? const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.mint,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rótulo auxiliar exibindo a frequência-alvo de uma nota, ex.: "110,0 Hz".
String noteFrequencyLabel(String noteName, {double a4 = kDefaultA4}) {
  final midi = nameToMidi(noteName);
  if (midi == null) return '';
  final frequency = midiToFrequency(midi.toDouble(), a4: a4);
  return '${frequency.toStringAsFixed(1).replaceAll('.', ',')} Hz';
}
