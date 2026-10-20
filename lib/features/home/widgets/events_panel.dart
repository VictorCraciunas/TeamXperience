import 'package:flutter/material.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/poster_card.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

class EventsPanel extends StatelessWidget {
  const EventsPanel({
    super.key,
    required this.events,
    required this.onTap,
    required this.onSeeAll,
  });

  final List<Event> events;
  final void Function(Event event) onTap;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Evenimente',
      count: events.isEmpty ? null : events.length,
      onAction: events.isEmpty ? null : onSeeAll,
      child:
          events.isEmpty
              ? Text(
                'Nu sunt evenimente programate momentan.',
                style: TextStyle(color: context.colors.muted, fontSize: 12),
              )
              : SizedBox(
                height: 128,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _poster(events[i]),
                ),
              ),
    );
  }

  Widget _poster(Event event) {
    final date = CalendarHelper.formatEventCardDate(event.dateEvent);

    return PosterCard(
      title: event.name ?? '',
      dateLabel: '${date['day']} ${date['month']}',
      place: event.location ?? '',
      imageUrl: event.landingImageUrl,
      onTap: () => onTap(event),
    );
  }
}
