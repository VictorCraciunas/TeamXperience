import 'package:flutter/widgets.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

import 'finish_recap.dart';

/// Whether the team's game is over for it: every mission solved, the event
/// ended, or the team already marked finished.
bool showFinish(Event event, Team team, {required bool eventEnded}) =>
    eventEnded || team.hasFinished || routeCompleted(event, team);

/// Whether the route should open the finish screen now. While a puzzle is
/// open on top of it ([routeOnTop] false) only the end of the event does: the
/// puzzle that solved the last mission is still writing, and it comes back to
/// the route with the team.
bool openFinishNow(Event event, Team team, {required bool eventEnded, required bool routeOnTop}) =>
    eventEnded || (routeOnTop && showFinish(event, team, eventEnded: false));

/// Closes whatever is open above [own] (a puzzle) and puts the finish screen
/// in its place. A route that is no longer on the navigator (already leaving)
/// changes nothing. Returns whether it navigated.
bool replaceWithFinish(NavigatorState navigator, Route<dynamic>? own, Map<String, Object?> arguments) {
  if (own == null || !own.isActive) return false;
  navigator.popUntil((route) => route == own);
  navigator.pushReplacementNamed(Routes.finish, arguments: arguments);
  return true;
}
