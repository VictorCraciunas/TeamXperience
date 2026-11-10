import 'dart:math';

import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/model/event.dart';

/// Whether [event] can be suggested to a player at [now]: public, still to
/// come, not one of theirs, and its enrolment open. Home's recommendation
/// uses the same rule.
bool isOpenSuggestion(Event event, Set<String> registeredIds, DateTime now) {
  final start = event.dateEvent;
  if (start == null || !start.isAfter(now)) return false;
  if (event.type != EventType.PUBLIC) return false;
  if (registeredIds.contains(event.eventId)) return false;
  final opens = event.dateStartEnrollment;
  final closes = event.dateDeadlineEnrollment;
  if (opens != null && opens.isAfter(now)) return false;
  if (closes != null && closes.isBefore(now)) return false;
  return true;
}

/// The events the Joacă pop-up can suggest, earliest first: the first one is
/// "Recomandat pentru tine", the rest come up at random with "Alt joc".
List<Event> openSuggestions(List<Event> all, Set<String> registeredIds, DateTime now) {
  final open = [for (final e in all) if (isOpenSuggestion(e, registeredIds, now)) e];
  open.sort((a, b) {
    final x = a.dateEvent;
    final y = b.dateEvent;
    if (x == null || y == null) return 0;
    return x.compareTo(y);
  });
  return open;
}

/// A random suggestion other than [current] out of [count]; [current] when
/// there is nothing else to pick.
int nextSuggestion(int current, int count, Random random) {
  if (count < 2) return current;
  final pick = random.nextInt(count - 1);
  return pick >= current ? pick + 1 : pick;
}
