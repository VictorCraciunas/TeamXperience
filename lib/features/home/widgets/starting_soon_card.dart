import 'package:flutter/material.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/ui.dart';

import 'game_badge.dart';
import 'game_card_button.dart';
import 'navy_game_card.dart';

/// The game has started and the start code can still be entered. Not drawn
/// in mockup 02; it uses the next-game card's frame.
class StartingSoonCard extends StatelessWidget {
  const StartingSoonCard({super.key, required this.event, required this.minutesLeft, required this.onEnterCode});

  final Event event;
  final int minutesLeft;
  final VoidCallback onEnterCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return NavyGameCard(
      fill: NavyFill.navy,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GameBadge(label: 'A început', fill: colors.soon, text: colors.onTick),
            ),
            const SizedBox(height: 8),
            Text(
              event.name ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45, color: colors.onNavy),
            ),
            Text(
              'Mai ai $minutesLeft min să intri',
              style: TextStyle(fontSize: 11, height: 1.45, color: colors.onNavy.withValues(alpha: .8)),
            ),
            const SizedBox(height: 12),
            GameCardButton(label: 'Introdu codul de start', onTap: onEnterCode),
          ],
        ),
      ),
    );
  }
}
