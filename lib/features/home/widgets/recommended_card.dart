import 'package:flutter/material.dart';
import 'package:teamxperience/features/events_tab/logic/event_card_texts.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/buttons/navy_button.dart';
import 'package:teamxperience/ui/components/event/event_picture.dart';
import 'package:teamxperience/ui/components/event/picture_chip.dart';
import 'package:teamxperience/ui/ui.dart';

import 'game_badge.dart';

/// An open event for a player with nothing registered: its picture leads,
/// then the name, the day and one clear button.
class RecommendedCard extends StatelessWidget {
  const RecommendedCard({super.key, required this.event, required this.onRegister});

  final Event event;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = event.dateEvent;
    final facts = cardRouteFacts(event);
    final radius = BorderRadius.circular(22);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            EventPicture(
              url: event.landingImageUrl,
              height: 170,
              topLeft: GameBadge(label: 'Recomandat pentru tine', fill: colors.tickOnNavy, text: colors.onTick),
              topRight: facts.isEmpty ? null : PictureChip(text: facts),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.name ?? '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
                  ),
                  if (start != null)
                    Text(
                      heroDateLine(start, event.punctDeStart),
                      style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted),
                    ),
                  const SizedBox(height: 12),
                  NavyButton(label: 'Înscrie-ți echipa', onPressed: onRegister),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
