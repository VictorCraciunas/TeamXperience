import 'package:teamxperience/features/event_details/logic/enrolment_window.dart';
import 'package:teamxperience/model/event.dart';

/// The Evenimente list's sections. Events that are over, and events whose
/// sign-up has closed for a player who is not in them, are not shown.
({List<Event> registered, List<Event> open, List<Event> soon}) sectionEvents(
  List<Event> events,
  Set<String> registeredIds,
  DateTime now,
) {
  final registered = <Event>[];
  final open = <Event>[];
  final soon = <Event>[];

  for (final e in events) {
    if (isOverAt(e, now)) continue;
    if (registeredIds.contains(e.eventId)) {
      registered.add(e);
    } else if (enrolmentNotOpenYet(e, now)) {
      soon.add(e);
    } else if (!enrolmentClosed(e, now)) {
      open.add(e);
    }
  }

  int bySoonest(Event a, Event b) {
    final da = a.dateEvent;
    final db = b.dateEvent;
    if (da == null || db == null) return da == null ? (db == null ? 0 : 1) : -1;
    return da.compareTo(db);
  }

  return (
    registered: registered..sort(bySoonest),
    open: open..sort(bySoonest),
    soon: soon..sort(bySoonest),
  );
}
