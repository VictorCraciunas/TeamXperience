import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// Where a team stands, as the organiser's live room sees it.
enum LiveState { notStarted, playing, waitingPhoto, stuck, finished, stopped }

/// A team with no mission solved for this long is stuck.
const stuckAfter = Duration(minutes: 20);

/// A team whose phones were not seen for this long has gone quiet.
const silentAfter = Duration(minutes: 5);

/// This many wrong answers on the current puzzle ask for the organiser's eye.
const wrongLimit = 3;

/// The event was stopped, or its time ran out. Like `Event.isOver`, with the
/// clock passed in.
bool eventEnded(Event event, DateTime now) {
  if (event.isStopped) return true;
  final start = event.dateEvent;
  return start != null && now.isAfter(start.add(event.playTime));
}

/// The event has started and has not ended.
bool isLive(Event event, DateTime now) {
  final start = event.dateEvent;
  return start != null && !now.isBefore(start) && !eventEnded(event, now);
}

/// When the team last moved forward: its latest mission, or its start.
DateTime? lastActivity(Team team) => team.lastMissionAt ?? team.startedAt;

/// Wrong answers on the puzzle the team is on.
int wrongOnCurrent(Team team) => team.attempts[Team.puzzleKey(team.missionProgress, team.puzzleNumber)] ?? 0;

/// The team's phones were seen once, and not for [silentAfter]. A team with no
/// phone seen yet is not silent: there is nothing to compare.
bool isSilent(Team team, DateTime now) {
  if (team.presence.isEmpty) return false;
  final newest = team.presence.values.reduce((a, b) => a.isAfter(b) ? a : b);
  return now.difference(newest) > silentAfter;
}

LiveState liveStateOf(Team team, {required int missionCount, required DateTime now, required bool eventOver}) {
  final completed = missionCount > 0 && team.missionProgress >= missionCount;
  if (completed) return LiveState.finished;
  if (team.hasFinished) return LiveState.stopped;
  if (!team.hasStarted) return LiveState.notStarted;
  if (team.photoApprovals.values.contains(PhotoApprovalStatus.pending)) return LiveState.waitingPhoto;
  // The phones write hasFinished only with the game open; a team whose phones
  // are closed has stopped all the same.
  if (eventOver) return LiveState.stopped;
  final last = lastActivity(team);
  if (last != null && now.difference(last) >= stuckAfter) return LiveState.stuck;
  return LiveState.playing;
}

/// The room's counts, from the same states as the board: a team the event
/// stopped is neither in play nor finished.
AdminEventStats liveCounts(List<Team> teams, {required int missionCount, required DateTime now, required bool eventOver}) {
  final states = [for (final team in teams) liveStateOf(team, missionCount: missionCount, now: now, eventOver: eventOver)];
  int count(Set<LiveState> wanted) => states.where(wanted.contains).length;
  return AdminEventStats(
    teams: teams.length,
    persons: teams.fold<int>(0, (sum, team) => sum + team.numberOfMembers),
    inPlay: count({LiveState.playing, LiveState.waitingPhoto, LiveState.stuck}),
    finished: count({LiveState.finished}),
    notStarted: count({LiveState.notStarted}),
  );
}
