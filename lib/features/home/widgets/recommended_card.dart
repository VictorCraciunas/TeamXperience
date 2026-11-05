import 'package:flutter/material.dart';
import 'package:teamxperience/features/events_tab/logic/event_card_texts.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/ui.dart';

import 'game_badge.dart';
import 'game_card_button.dart';
import 'navy_game_card.dart';

/// An open event for a player with nothing registered. Not drawn in mockup
/// 02; it uses the next-game card's frame.
class RecommendedCard extends StatelessWidget {
  const RecommendedCard({super.key, required this.event, required this.onRegister});

  final Event event;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = event.dateEvent;
    final facts = cardRouteFacts(event);
    final line = [
      if (start != null) heroDateLine(start, event.punctDeStart),
      if (facts.isNotEmpty) facts,
    ].join(' · ');

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
              child: GameBadge(label: 'Recomandat pentru tine', fill: colors.tickOnNavy, text: colors.onTick),
            ),
            const SizedBox(height: 8),
            Text(
              event.name ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45, color: colors.onNavy),
            ),
            if (line.isNotEmpty)
              Text(line, style: TextStyle(fontSize: 11, height: 1.45, color: colors.onNavy.withValues(alpha: .8))),
            const SizedBox(height: 12),
            GameCardButton(label: 'Înscrie-ți echipa', onTap: onRegister),
          ],
        ),
      ),
    );
  }
}
