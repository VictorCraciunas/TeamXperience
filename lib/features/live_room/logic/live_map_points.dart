import 'package:teamxperience/model/team.dart';

import 'live_status.dart';

/// The colour family of a team's pin.
enum PinTone { playing, stuck, finished, silent }

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
