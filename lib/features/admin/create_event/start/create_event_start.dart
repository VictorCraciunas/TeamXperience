import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/event.dart';

/// How the organiser chose to begin an event: the [route] to open and the
/// [arguments] to open it with.
sealed class CreateEventStart {
  const CreateEventStart();

  /// The event form, unless a start says otherwise.
  String get route => Routes.createEvent;

  Map<String, dynamic> get arguments;
}

/// An event written outside the app, pasted as JSON.
class StartFromJson extends CreateEventStart {
  const StartFromJson();

  @override
  String get route => Routes.importEvent;

  @override
  Map<String, dynamic> get arguments => const {};
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
