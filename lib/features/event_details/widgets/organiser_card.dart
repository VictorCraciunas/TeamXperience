import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// Who runs the event, how many events they ran, and a message button.
class OrganiserCard extends StatelessWidget {
  const OrganiserCard({super.key, required this.name, required this.eventsCount, this.onMessage});

  final String name;
  final int eventsCount;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final message = onMessage;
    return OutlineCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.navy),
            child: Text(initialsOf(name), style: AppTextStyles.cardTitle(context).copyWith(color: colors.onNavy)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.cardTitle(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  eventsCount == 1 ? 'un eveniment organizat' : '$eventsCount evenimente organizate',
                  style: AppTextStyles.smallMuted(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (message != null)
            // As tall as the circle, so the card keeps the mockup's height.
            Semantics(
              button: true,
              label: 'Scrie-i organizatorului',
              child: InkResponse(
                onTap: message,
                radius: 22,
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(TablerIcons.message_circle, size: 18, color: colors.accent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
