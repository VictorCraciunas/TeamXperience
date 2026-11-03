import 'package:teamxperience/model/event.dart';

/// Where an event stands at [now], for the badge and the bar of its page.
/// Reads [now] instead of the clock, so `Event.isOver` is not used.

bool isOverAt(Event e, DateTime now) {
  final start = e.dateEvent;
  return e.isStopped || (start != null && now.isAfter(start.add(Event.maxDuration)));
}

/// From the start to [Event.enterWindow] after it, the last minute included.
bool inEnterWindow(Event e, DateTime now) {
  final start = e.dateEvent;
  return start != null && !now.isBefore(start) && !now.isAfter(start.add(Event.enterWindow));
}

/// Whole minutes left to type the start code, rounded up.
int enterMinutesLeft(Event e, DateTime now) {
  final start = e.dateEvent;
  if (start == null) return 0;
  final left = start.add(Event.enterWindow).difference(now).inSeconds;
  return left <= 0 ? 0 : (left / 60).ceil();
}

/// The calendar day of [d], in UTC so a clock change does not shorten it.
DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

bool enrolmentNotOpenYet(Event e, DateTime now) {
  final opens = e.dateStartEnrollment;
  return opens != null && now.isBefore(opens);
}

/// When sign-up really ends: the deadline's own time, or the end of its day
/// when it is set to midnight (a deadline given as a date only).
DateTime? _closesAt(Event e) {
  final deadline = e.dateDeadlineEnrollment;
  if (deadline == null) return null;
  final midnight = deadline.hour == 0 && deadline.minute == 0 && deadline.second == 0;
  return midnight ? DateTime(deadline.year, deadline.month, deadline.day, 23, 59, 59) : deadline;
}

/// Closed once the deadline has passed, or once the event has started.
bool enrolmentClosed(Event e, DateTime now) {
  final start = e.dateEvent;
  if (start != null && !now.isBefore(start)) return true;
  final closes = _closesAt(e);
  return closes != null && now.isAfter(closes);
}

/// Calendar days until the deadline (0 on its day), or null without one.
int? enrolmentDaysLeft(Event e, DateTime now) {
  final deadline = e.dateDeadlineEnrollment;
  if (deadline == null) return null;
  return _day(deadline).difference(_day(now)).inDays;
}
