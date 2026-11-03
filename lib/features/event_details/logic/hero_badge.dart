import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'enrolment_window.dart';

enum HeroBadgeKind { open, soon, live, closed }

/// The pill above the event name on the hero.
class HeroBadge {
  const HeroBadge(this.kind, this.label);

  final HeroBadgeKind kind;
  final String label;
}

/// The badge for [e] at [now], or null once the event is over.
HeroBadge? heroBadge(Event e, DateTime now) {
  if (isOverAt(e, now)) return null;
  if (inEnterWindow(e, now)) return const HeroBadge(HeroBadgeKind.live, 'LIVE');

  final opens = e.dateStartEnrollment;
  if (opens != null && enrolmentNotOpenYet(e, now)) {
    return HeroBadge(HeroBadgeKind.soon, 'Înscrieri de pe ${dayAndMonth(opens)}');
  }
  if (enrolmentClosed(e, now)) return const HeroBadge(HeroBadgeKind.closed, 'Înscrieri închise');

  final days = enrolmentDaysLeft(e, now);
  final left = switch (days) {
    null => '',
    0 => ' · ultima zi',
    1 => ' · încă o zi',
    _ => ' · încă $days zile',
  };
  return HeroBadge(HeroBadgeKind.open, 'Înscrieri deschise$left');
}
