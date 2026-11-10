import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The colours of the nearest event palette, and one line in its voice font.
class ParchmentSwatches extends StatelessWidget {
  const ParchmentSwatches({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.eventPalette;
    final swatches = [p.background, p.surface, p.border, p.ink, p.muted, p.faint, p.accent, p.secondaryAccent, p.danger, p.routeDash];

    return ColoredBox(
      color: p.background,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in swatches)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: p.border),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Dragi exploratori, harta mea a rămas neterminată.',
              style: TextStyle(fontFamily: p.voiceFont, fontSize: 15, color: p.ink, height: 1.45),
            ),
            Text('— Cartograful', style: TextStyle(fontFamily: p.voiceFont, fontSize: 12, color: p.accent)),
          ],
        ),
      ),
    );
  }
}
