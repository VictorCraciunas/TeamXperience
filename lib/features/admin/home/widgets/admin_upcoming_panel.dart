import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_row.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

class AdminUpcomingPanel extends StatelessWidget {
  const AdminUpcomingPanel({
    super.key,
    required this.events,
    required this.statsFor,
    required this.onTap,
    required this.onSeeAll,
  });

  final List<Event> events;
  final AdminEventStats Function(Event event) statsFor;
  final void Function(Event event) onTap;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Evenimente viitoare',
      count: events.length,
      onAction: onSeeAll,
      child: events.isEmpty
          ? Text(
              'Nu ai evenimente programate.',
              style: TextStyle(color: context.colors.muted, fontSize: 12),
            )
          : Column(
              children: [
                for (var i = 0; i < events.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  _row(context, events[i]),
                ],
              ],
            ),
    );
  }

  Widget _row(BuildContext context, Event event) {
    final date = CalendarHelper.formatEventCardDate(event.dateEvent);
    final stats = statsFor(event);
    final colors = context.colors;

    return EventRow(
      title: event.name ?? '',
      subtitle: event.location ?? '',
      dayLabel: date['day'] ?? '',
      monthLabel: date['month'] ?? '',
      onTap: () => onTap(event),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${stats.teams} echipe',
            style: TextStyle(color: colors.text, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            '${stats.persons} pers.',
            style: TextStyle(color: colors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
