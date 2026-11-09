import 'package:flutter/material.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_row.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

/// Lets the organiser pick the event to copy. Resolves to the event, or null
/// when closed without choosing.
Future<Event?> showOldEventPicker(BuildContext context, List<Event> events) {
  return showModalBottomSheet<Event>(
    context: context,
    isScrollControlled: true,
    builder: (_) => OldEventPickerSheet(events: events),
  );
}

class OldEventPickerSheet extends StatelessWidget {
  const OldEventPickerSheet({super.key, required this.events});

  final List<Event> events;

  /// Newest first; events without a date go last.
  List<Event> get _sorted {
    final sorted = [...events];
    sorted.sort((a, b) {
      final first = a.dateEvent;
      final second = b.dateEvent;
      if (first == null && second == null) return 0;
      if (first == null) return 1;
      if (second == null) return -1;
      return second.compareTo(first);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sorted = _sorted;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          children: [
            Text(
              'Alege un eveniment',
              style: TextStyle(
                color: colors.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Se copiază misiunile și puzzle-urile, fără coduri și răspunsuri.',
              style: TextStyle(color: colors.muted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            for (final event in sorted) ...[
              _row(context, event),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Event event) {
    final date = CalendarHelper.formatEventCardDate(event.dateEvent);

    return EventRow(
      title: event.name ?? '',
      subtitle: event.location ?? '',
      dayLabel: date['day'] ?? '',
      monthLabel: date['month'] ?? '',
      onTap: () => Navigator.of(context).pop(event),
    );
  }
}
