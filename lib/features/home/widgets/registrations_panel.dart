import 'package:flutter/material.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_row.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

class RegistrationsPanel extends StatelessWidget {
  const RegistrationsPanel({
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
    if (events.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Înscrierile tale',
      count: events.length,
      onAction: onSeeAll,
      child: Column(
        children: [
          for (var i = 0; i < events.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _row(events[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(Event event) {
    final date = CalendarHelper.formatEventCardDate(event.dateEvent);
    final location = event.location;
    final parts = [
      CalendarHelper.formatEventTime(event.dateEvent),
      if (location != null && location.isNotEmpty) location,
    ];

    return EventRow(
      title: event.name ?? '',
      subtitle: parts.join(' · '),
      dayLabel: date['day'] ?? '',
      monthLabel: date['month'] ?? '',
      onTap: () => onTap(event),
    );
  }
}
