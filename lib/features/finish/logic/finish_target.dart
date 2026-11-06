import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

import 'finish_recap.dart';

/// Whether the team's game is over for it: every mission solved, the event
/// ended, or the team already marked finished.
bool showFinish(Event event, Team team, {required bool eventEnded}) =>
    eventEnded || team.hasFinished || routeCompleted(event, team);
