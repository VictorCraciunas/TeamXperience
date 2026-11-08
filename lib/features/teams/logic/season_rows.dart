import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/ui/components/team/leaderboard_row.dart';

/// The leaderboard's rows, in the order given, the player's crews highlighted.
List<LeaderboardRow> seasonRows(List<SeasonStanding> standings, Set<String> myCrewIds) => [
      for (var i = 0; i < standings.length; i++)
        LeaderboardRow(
          place: i + 1,
          name: standings[i].crewName,
          score: '${standings[i].points} p',
          own: myCrewIds.contains(standings[i].crewId),
        ),
    ];

/// "1 joc", "3 jocuri", "20 de jocuri" and friends for a crew's card.
String gamesLabel(int n) => n == 1 ? 'joc' : 'jocuri';

String winsLabel(int n) => n == 1 ? 'victorie' : 'victorii';
