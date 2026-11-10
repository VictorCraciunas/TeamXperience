import 'package:teamxperience/service/leaderboard.dart';
import 'package:teamxperience/ui/components/team/leaderboard_card.dart';

/// [ranked] as leaderboard rows: "4/6" (or "–" without missions), and the
/// player's team as "{name} · voi".
List<LeaderboardRow> leaderboardRows(List<RankedTeam> ranked, {required String ownName, required int missionCount}) {
  return [
    for (final r in ranked)
      LeaderboardRow(
        place: r.place,
        name: r.team.name == ownName ? '${r.team.name} · voi' : r.team.name,
        score: missionCount <= 0 ? '–' : '${r.mission}/$missionCount',
        own: r.team.name == ownName,
      ),
  ];
}
