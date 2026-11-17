import 'package:teamxperience/model/event.dart';

/// The registered events whose team chat can still get organiser messages:
/// those not over (stopped or past their time) by [now].
List<Event> eventsToWatch(List<Event> registered, DateTime now) =>
    [for (final event in registered) if (!event.isOverAt(now)) event];
