import 'package:teamxperience/model/event.dart';

/// How the organiser chose to begin an event. [arguments] are what the event
/// form (`Routes.createEvent`) is opened with.
sealed class CreateEventStart {
  const CreateEventStart();

  Map<String, dynamic> get arguments;
}

/// An empty form.
class StartFromScratch extends CreateEventStart {
  const StartFromScratch();

  @override
  Map<String, dynamic> get arguments => {'event': null};
}

/// A copy of an event that was already published.
class StartFromEvent extends CreateEventStart {
  const StartFromEvent(this.event);

  final Event event;

  @override
  Map<String, dynamic> get arguments => {'event': event, 'isBlueprint': true};
}

/// An unfinished event, carried on where it was left.
class StartFromDraft extends CreateEventStart {
  const StartFromDraft(this.event);

  final Event event;

  @override
  Map<String, dynamic> get arguments => {'event': event, 'isDraft': true};
}
