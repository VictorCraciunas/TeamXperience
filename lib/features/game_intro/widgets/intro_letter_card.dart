import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The organiser's letter on the intro (mockup 05): a surface card in the
/// event's serif, signed at the right in italics.
class IntroLetterCard extends StatelessWidget {
  const IntroLetterCard({super.key, required this.letter, this.signature});

  final String letter;
  final String? signature;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final style = TextStyle(fontFamily: palette.voiceFont, fontSize: 16, height: 1.55, color: palette.ink);
    final name = signature?.trim() ?? '';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        // The mockup's 12 / 14, plus the 1 px border drawn inside.
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(letter, style: style),
            if (name.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('— $name', textAlign: TextAlign.right, style: style.copyWith(fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}
