import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// One fact under the intro letter ("6 misiuni"): a surface pill with a
/// 12 px icon and 11 px text.
class IntroFactChip extends StatelessWidget {
  const IntroFactChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        // The mockup's 3 / 10, plus the 1 px border drawn inside.
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: palette.ink),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: TextStyle(fontSize: 13, height: 1.45, color: palette.ink))),
          ],
        ),
      ),
    );
  }
}
