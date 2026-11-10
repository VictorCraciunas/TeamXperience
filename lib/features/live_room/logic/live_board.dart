import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/leaderboard.dart';

import 'live_status.dart';

/// "Toate", "Blocate", "Neporniți".
enum BoardFilter { all, stuck, notStarted }

/// One team on the organiser's progress board.
class BoardRow {
  const BoardRow({required this.team, this.place, required this.done, required this.state, this.since});

  final Team team;

  /// 1 for the leader; null for a team that has not started.
  final int? place;

  /// Missions solved, at most the event's mission count.
  final int done;
  final LiveState state;

  /// When the team last moved forward.
  final DateTime? since;
}

/// The board: teams in play in leaderboard order, then those that have not
/// started, by name, without a place.
List<BoardRow> boardRows(
  List<Team> teams, {
  required int missionCount,
  required DateTime now,
  required bool eventOver,
  BoardFilter filter = BoardFilter.all,
}) {
  bool started(Team t) => t.hasStarted || t.hasFinished;
  LiveState state(Team t) => liveStateOf(t, missionCount: missionCount, now: now, eventOver: eventOver);
  int done(Team t) => t.missionProgress.clamp(0, missionCount < 0 ? 0 : missionCount);

  final ranked = rankTeams(teams.where(started).toList(), missionCount: missionCount);
  final waiting = teams.where((t) => !started(t)).toList()..sort((a, b) => a.name.compareTo(b.name));
  final rows = [
    for (final entry in ranked)
      BoardRow(
        team: entry.team,
        place: entry.place,
        done: done(entry.team),
        state: state(entry.team),
        since: lastActivity(entry.team),
      ),
    for (final team in waiting) BoardRow(team: team, done: done(team), state: state(team)),
  ];
  return switch (filter) {
    BoardFilter.all => rows,
    BoardFilter.stuck => rows.where((r) => r.state == LiveState.stuck).toList(),
    BoardFilter.notStarted => rows.where((r) => r.state == LiveState.notStarted).toList(),
  };
}
