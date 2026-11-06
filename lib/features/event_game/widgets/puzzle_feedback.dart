import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/event_game/logic/puzzle_rules.dart';
import 'package:teamxperience/ui/components/game/attempt_dots.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// Under a code puzzle (mockup 06): the organiser's wrong-answer line in the
/// danger colour, then the attempts left. While the puzzle is locked, the
/// countdown takes their place.
class PuzzleFeedback extends StatelessWidget {
  const PuzzleFeedback({super.key, this.wrong, this.maxAttempts, this.attemptsLeft, this.lockLeft});

  final String? wrong;
  final int? maxAttempts;
  final int? attemptsLeft;
  final Duration? lockLeft;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final lock = lockLeft;
    if (lock != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(TablerIcons.hourglass, size: 14, color: palette.muted),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                lockLine(lock),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: palette.muted),
              ),
            ),
          ],
        ),
      );
    }

    final line = wrong;
    final max = maxAttempts;
    final left = attemptsLeft;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (line != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(TablerIcons.alert_circle, size: 14, color: palette.danger),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    line,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: palette.danger),
                  ),
                ),
              ],
            ),
          ),
        if (max != null && left != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AttemptDots(max: max, left: left),
          ),
      ],
    );
  }
}
