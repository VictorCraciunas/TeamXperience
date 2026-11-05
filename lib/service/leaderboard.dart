import 'package:teamxperience/model/team.dart';

/// A team with its place in the event and the mission it is on.
class RankedTeam {
  const RankedTeam({required this.team, required this.place, required this.mission});

  final Team team;

  /// 1 for the leader; every team has its own place.
  final int place;

  /// The mission the team is on (the total once it has finished); 0 for an
  /// event without missions.
  final int mission;
}

/// The event's teams in leaderboard order: finished teams first, then more
/// missions solved, then whoever solved their last mission earlier (teams
/// without a time after those with one), then by name. The player's live
/// Home and the organiser's board both use it.
List<RankedTeam> rankTeams(List<Team> teams, {required int missionCount}) {
  final sorted = [...teams]..sort(_compare);
  return [
    for (var i = 0; i < sorted.length; i++)
      RankedTeam(team: sorted[i], place: i + 1, mission: _mission(sorted[i], missionCount)),
  ];
}

int _compare(Team a, Team b) {
  if (a.hasFinished != b.hasFinished) return a.hasFinished ? -1 : 1;
  final byProgress = b.missionProgress.compareTo(a.missionProgress);
  if (byProgress != 0) return byProgress;
  final aLast = a.lastMissionAt;
  final bLast = b.lastMissionAt;
  if (aLast != null && bLast != null) {
    final byTime = aLast.compareTo(bLast);
    if (byTime != 0) return byTime;
  } else if (aLast != null || bLast != null) {
    return aLast != null ? -1 : 1;
  }
  return a.name.compareTo(b.name);
}

int _mission(Team team, int missionCount) {
  if (missionCount <= 0) return 0;
  if (team.hasFinished) return missionCount;
  return (team.missionProgress + 1).clamp(1, missionCount);
}
