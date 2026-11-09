import 'package:flutter/material.dart';
import 'package:teamxperience/features/events_tab/logic/event_card_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_grid_card.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// A titled two-column grid of events ("Evenimente noi", "Jocuri trecute").
/// Nothing when there are none.
class EventsGridSection extends StatelessWidget {
  const EventsGridSection({
    super.key,
    required this.title,
    this.link,
    this.onLink,
    required this.events,
    required this.onTap,
  });

  final String title;
  final String? link;
  final VoidCallback? onLink;
  final List<Event> events;
  final ValueChanged<Event> onTap;

  static const double _gap = 8;

  Widget _card(Event event) {
    final start = event.dateEvent;
    return EventGridCard(
      title: event.name ?? '',
      date: start == null ? '' : dayAndMonth(start),
      facts: cardRouteFacts(event),
      imageUrl: event.landingImageUrl,
      onTap: () => onTap(event),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: title, link: link, onLink: onLink, top: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < events.length; i += 2) ...[
                if (i > 0) const SizedBox(height: _gap),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _card(events[i])),
                      const SizedBox(width: _gap),
                      Expanded(child: i + 1 < events.length ? _card(events[i + 1]) : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
