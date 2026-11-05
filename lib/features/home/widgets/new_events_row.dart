import 'package:flutter/material.dart';
import 'package:teamxperience/features/events_tab/logic/event_card_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_mini_card.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// "Evenimente noi" on Home (mockup 02): open events as small cards in a
/// sideways row. Nothing when there are none.
class NewEventsRow extends StatelessWidget {
  const NewEventsRow({super.key, required this.events, required this.onTap, required this.onAll});

  final List<Event> events;
  final void Function(Event) onTap;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: 'Evenimente noi', link: 'Vezi toate', onLink: onAll, top: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < events.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _card(events[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _card(Event event) {
    final start = event.dateEvent;
    final url = event.landingImageUrl;
    return EventMiniCard(
      title: event.name ?? '',
      date: start == null ? '' : dayAndMonth(start),
      facts: cardRouteFacts(event),
      imageUrl: url == null || url.isEmpty ? null : url,
      onTap: () => onTap(event),
    );
  }
}
