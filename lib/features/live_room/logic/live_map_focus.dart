import 'package:latlong2/latlong.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

import 'live_map_points.dart';

/// What the big map opens with: the event and, from the team sheet's "Hartă",
/// the team to centre on. A bare `Event` still opens it (Admin Home, the
/// room's "Hartă mare").
class LiveMapArgs {
  const LiveMapArgs(this.event, {this.focusTeam});

  final Event event;

  /// The team's name (its document id).
  final String? focusTeam;
}

/// The big map's route arguments, read: a bare `Event` or [LiveMapArgs];
/// null for anything else.
LiveMapArgs? liveMapArgsOf(Object? arguments) {
  if (arguments is LiveMapArgs) return arguments;
  if (arguments is Event) return LiveMapArgs(arguments);
  return null;
}

/// A request to centre the map on one team. Each request is a new object
/// (no value equality), so asking for the same team again, after the
/// organiser moved the map away, brings it back.
class TeamFocus {
  TeamFocus(this.teamName);

  final String teamName;
}

/// The focused team's last position; null without a focus or when the team
/// has no pin yet.
LatLng? focusPointOf(TeamFocus? focus, List<Team> teams) {
  if (focus == null) return null;
  for (final team in teams) {
    if (team.name == focus.teamName && hasPin(team)) return LatLng(team.latitude, team.longitude);
  }
  return null;
}
