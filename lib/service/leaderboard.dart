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

/// The event's teams in leaderboard order: teams that solved every mission
/// first (the earlier `finishedAt` ahead), then more missions solved, then
/// whoever solved their last mission earlier (teams without a time after
/// those with one), then by name. A team the event stopped early is marked
/// `hasFinished` but ranks by its missions. The player's live Home, the
/// finish screen and the organiser's board use it.
List<RankedTeam> rankTeams(List<Team> teams, {required int missionCount}) {
  bool done(Team t) => _completed(t, missionCount);
  int compare(Team a, Team b) {
    if (done(a) != done(b)) return done(a) ? -1 : 1;
    if (done(a)) {
      // A finish time that was never written falls back to the last mission.
      final byFinish = _earlierFirst(a.finishedAt ?? a.lastMissionAt, b.finishedAt ?? b.lastMissionAt);
      if (byFinish != 0) return byFinish;
    }
    return _compare(a, b);
  }

  final sorted = [...teams]..sort(compare);
  return [
    for (var i = 0; i < sorted.length; i++)
      RankedTeam(team: sorted[i], place: i + 1, mission: _mission(sorted[i], missionCount)),
  ];
}

bool _completed(Team team, int missionCount) => missionCount > 0 && team.missionProgress >= missionCount;

/// Earlier time first; a missing time after a present one; 0 when equal or
/// both missing.
int _earlierFirst(DateTime? a, DateTime? b) {
  if (a != null && b != null) return a.compareTo(b);
  if (a != null || b != null) return a != null ? -1 : 1;
  return 0;
}

int _compare(Team a, Team b) {
  final byProgress = b.missionProgress.compareTo(a.missionProgress);
  if (byProgress != 0) return byProgress;
  final byTime = _earlierFirst(a.lastMissionAt, b.lastMissionAt);
  if (byTime != 0) return byTime;
  return a.name.compareTo(b.name);
}

int _mission(Team team, int missionCount) {
  if (missionCount <= 0) return 0;
  if (_completed(team, missionCount)) return missionCount;
  return (team.missionProgress + 1).clamp(1, missionCount);
}
