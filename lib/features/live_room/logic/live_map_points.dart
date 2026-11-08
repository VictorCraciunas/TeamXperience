import 'package:latlong2/latlong.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

import 'live_status.dart';

/// The colour family of a team's pin.
enum PinTone { playing, stuck, finished, silent }

/// The route line: the start pin, then every mission that has a pin.
List<LatLng> routePoints(Event event) {
  final startLat = event.startLatitude;
  final startLng = event.startLongitude;
  return [
    if (startLat != null && startLng != null) LatLng(startLat, startLng),
    for (final mission in event.missions)
      if (mission.latitude case final lat? when mission.longitude != null) LatLng(lat, mission.longitude ?? 0),
  ];
}

/// A team gets a pin once it has started and has sent a position: (0, 0) is
/// what a team holds before its first one.
bool hasPin(Team team) => (team.hasStarted || team.hasFinished) && !(team.latitude == 0 && team.longitude == 0);

/// Teal when finished, amber when stuck, grey when its phones went quiet or
/// the event stopped it, navy otherwise.
PinTone pinToneOf(Team team, {required int missionCount, required DateTime now, required bool eventOver}) {
  final state = liveStateOf(team, missionCount: missionCount, now: now, eventOver: eventOver);
  if (state == LiveState.finished) return PinTone.finished;
  if (state == LiveState.stopped) return PinTone.silent;
  if (state == LiveState.stuck) return PinTone.stuck;
  return !eventOver && isSilent(team, now) ? PinTone.silent : PinTone.playing;
}
