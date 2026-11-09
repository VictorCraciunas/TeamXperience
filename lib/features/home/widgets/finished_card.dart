import 'package:flutter/material.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/ui.dart';

import 'game_badge.dart';
import 'game_card_button.dart';
import 'navy_game_card.dart';

/// The team is done but the event still runs: the results come when it ends.
class FinishedCard extends StatelessWidget {
  const FinishedCard({super.key, required this.event, required this.onOpen});

  final Event event;
  final VoidCallback onOpen;

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
              child: GameBadge(label: 'Ați terminat', fill: colors.tickOnNavy, text: colors.onTick),
            ),
            const SizedBox(height: 8),
            Text(
              event.name ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.45, color: colors.onNavy),
            ),
            Text(
              'Rezultatele, kilometrii și XP-ul apar când se încheie evenimentul.',
              style: TextStyle(fontSize: 13, height: 1.45, color: colors.onNavy.withValues(alpha: .8)),
            ),
            const SizedBox(height: 12),
            GameCardButton(label: 'Vezi clasamentul', onTap: onOpen),
          ],
        ),
      ),
    );
  }
}
