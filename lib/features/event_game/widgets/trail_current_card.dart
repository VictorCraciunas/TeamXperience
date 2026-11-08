import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/pulse_dot.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The mission the team is on, as a card on the trail (mockup 06): 140 wide
/// inside 10 px padding and a 2 px second-accent border (164 in all), the
/// "Misiunea 4 · acum" line, the title in the event's voice font, the
/// distance, and "Continuă".
class TrailCurrentCard extends StatelessWidget {
  const TrailCurrentCard({
    super.key,
    required this.number,
    required this.title,
    required this.onContinue,
    this.distance,
  });

  static const double width = 164;

  final int number;
  final String title;
  final String? distance;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final far = distance;
    // The whole card opens the mission: 'Continuă' itself is smaller than a finger.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onContinue,
      child: SizedBox(
        width: width,
        child: DecoratedBox(
          key: const ValueKey('trail-card'),
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border.all(color: palette.secondaryAccent, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            // The mockup's 8 / 10, plus the 2 px border drawn inside.
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    PulseDot(colour: palette.accent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Misiunea $number · acum',
                        style: TextStyle(fontSize: 11, height: 1.45, fontWeight: FontWeight.w500, color: palette.accent),
                      ),
                    ),
                  ],
                ),
                Text(
                  title,
                  style: TextStyle(fontFamily: palette.voiceFont, fontSize: 14, height: 1.45, color: palette.ink),
                ),
                if (far != null) Text(far, style: TextStyle(fontSize: 11, height: 1.45, color: palette.muted)),
                const SizedBox(height: 6),
                Semantics(
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onContinue,
                    child: DecoratedBox(
                      key: const ValueKey('trail-continue'),
                      decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          'Continuă',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: palette.onAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
