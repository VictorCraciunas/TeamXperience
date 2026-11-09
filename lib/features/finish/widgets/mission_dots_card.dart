import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The route in one line (mockup 08): a 12 px dot per mission joined by 2 px
/// lines, then the flag; under it the fastest mission and the hints.
class MissionDotsCard extends StatelessWidget {
  const MissionDotsCard({super.key, required this.missions, required this.solved, this.fastest, required this.hints});

  final int missions;
  final int solved;
  final String? fastest;
  final String hints;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final quick = fastest;
    final small = TextStyle(fontSize: 13, height: 1.45, color: palette.ink.withValues(alpha: .8));

    Widget dot(int i) {
      final done = i < solved;
      return DecoratedBox(
        key: ValueKey(done ? 'mission-dot-done-$i' : 'mission-dot-$i'),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? palette.accent : null,
          border: done ? null : Border.all(color: palette.accent, width: 2),
        ),
        child: const SizedBox.square(dimension: 12),
      );
    }

    Widget line(bool done) => Expanded(
          child: Container(height: 2, color: done ? palette.accent : palette.accent.withValues(alpha: .35)),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (var i = 0; i < missions; i++) ...[dot(i), line(i < solved)],
                Icon(TablerIcons.flag, size: 15, color: palette.accent),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (quick != null) Expanded(child: Text(quick, style: small)) else const Spacer(),
                const SizedBox(width: 8),
                Text(hints, style: small),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
