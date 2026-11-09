import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/game/round_icon_button.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The top of a puzzle (mockup 06): back, "Misiunea 4 din 6" over the
/// mission's title in the event's voice font, and the played clock.
class PuzzleHeader extends StatelessWidget {
  const PuzzleHeader({
    super.key,
    required this.mission,
    required this.missions,
    required this.title,
    required this.clock,
    required this.onBack,
  });

  final int mission;
  final int missions;
  final String title;
  final String clock;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    return Padding(
      // The back button's 48 px tap area takes up 8 of the mockup's padding.
      padding: const EdgeInsets.fromLTRB(6, 4, 14, 0),
      child: Row(
        children: [
          RoundIconButton(icon: TablerIcons.arrow_left, label: 'Înapoi', onTap: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Misiunea $mission din $missions',
                    style: TextStyle(fontSize: 13, height: 1.45, color: palette.muted),
                  ),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: palette.voiceFont, fontSize: 17, height: 1.45, color: palette.ink),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            clock,
            style: TextStyle(
              fontFamily: 'Monospace',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.45,
              color: palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}
