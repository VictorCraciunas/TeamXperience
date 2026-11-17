import 'package:teamxperience/model/team.dart';

/// The three numbers above the list: teams, players who joined, and teams
/// that still wait for players.
class TeamStats {
  const TeamStats({required this.teams, required this.players, required this.incomplete});

  final int teams;
  final int players;
  final int incomplete;
}

/// The players who actually joined [team] (not the size it signed up for).
int joinedCount(Team team) => team.userIds.length;

/// Fewer players joined than [team] signed up for. A team without a size
/// (old data) is never incomplete.
bool isIncomplete(Team team) => joinedCount(team) < team.numberOfMembers;

TeamStats teamStats(List<Team> teams) => TeamStats(
      teams: teams.length,
      players: teams.fold(0, (sum, team) => sum + joinedCount(team)),
      incomplete: teams.where(isIncomplete).length,
    );
