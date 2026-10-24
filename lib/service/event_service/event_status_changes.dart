import '../../enums/event_status.dart';
import '../../exceptions/events_exceptions.dart';
import '../../model/event.dart';
import 'event_completeness.dart';

/// Marks [event] as a draft saved at [now], remembering the wizard step it was
/// left at. Nothing has to be filled in, that is the point of a draft.
Event asDraft(Event event, {required DateTime now, int? wizardStep}) {
  event
    ..status = EventStatus.draft
    ..updatedAt = now
    ..wizardStep = wizardStep ?? event.wizardStep;
  return event;
}

/// Marks [event] as published at [now]. Throws [EventNotPublishableException]
/// listing everything that is missing, and then leaves [event] untouched.
Event asPublished(Event event, {required DateTime now}) {
  final problems = publishProblems(event);
  if (problems.isNotEmpty) {
    throw EventNotPublishableException([for (final p in problems) p.text]);
  }

  event
    ..status = EventStatus.published
    ..updatedAt = now
    ..nrMissions = event.missions.length;
  return event;
}
