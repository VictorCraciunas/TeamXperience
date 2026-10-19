import 'package:teamxperience/model/team.dart';

/// Team numbers for one event, shown on the admin Home.
class AdminEventStats {
  const AdminEventStats({
    this.teams = 0,
    this.persons = 0,
    this.finished = 0,
    this.inPlay = 0,
  });

  factory AdminEventStats.fromTeams(List<Team> teams) {
    return AdminEventStats(
      teams: teams.length,
      persons: teams.fold<int>(0, (sum, team) => sum + team.numberOfMembers),
      finished: teams.where((t) => t.hasFinished).length,
      inPlay: teams.where((t) => t.hasStarted && !t.hasFinished).length,
    );
  }

  final int teams;
  final int persons;
  final int finished;
  final int inPlay;
}
