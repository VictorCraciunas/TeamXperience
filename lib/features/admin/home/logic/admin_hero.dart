import 'package:teamxperience/model/event.dart';

/// How far ahead an event counts as "starting soon" on the admin Home.
const Duration adminSoonWindow = Duration(hours: 24);

sealed class AdminHero {
  const AdminHero();
}

class AdminLiveHero extends AdminHero {
  const AdminLiveHero(this.event);

  final Event event;
}

class AdminSoonHero extends AdminHero {
  const AdminSoonHero(this.event, this.untilStart);

  final Event event;
  final Duration untilStart;
}

class NoAdminHero extends AdminHero {
  const NoAdminHero();
}

/// Picks what the admin Home hero shows: a live event first, otherwise the
/// nearest event starting within [adminSoonWindow].
AdminHero resolveAdminHero({
  required DateTime now,
  required List<Event> events,
}) {
  Event? live;
  Event? soon;

  for (final event in events) {
    final start = event.dateEvent;
    if (start == null) continue;

    if (!start.isAfter(now)) {
      final over = event.isStopped || now.isAfter(start.add(Event.maxDuration));
      if (over) continue;
      final current = live?.dateEvent;
      if (current == null || start.isBefore(current)) live = event;
    } else if (start.difference(now) <= adminSoonWindow) {
      final current = soon?.dateEvent;
      if (current == null || start.isBefore(current)) soon = event;
    }
  }

  final liveEvent = live;
  if (liveEvent != null) return AdminLiveHero(liveEvent);

  final soonEvent = soon;
  final soonStart = soonEvent?.dateEvent;
  if (soonEvent != null && soonStart != null) {
    return AdminSoonHero(soonEvent, soonStart.difference(now));
  }
  return const NoAdminHero();
}
