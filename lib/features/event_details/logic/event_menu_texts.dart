import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// "5 echipe", "20 de echipe": Romanian puts "de" before 20 and up, except
/// after a remainder of 1 to 19 ("101 echipe").
String _many(int n, String word) {
  final rest = n % 100;
  final de = n >= 20 && (rest == 0 || rest >= 20);
  return de ? '$n de $word' : '$n $word';
}

/// Where the event stands, in a word: "ciornă", "oprit", "încheiat",
/// "în desfășurare" or "publicat".
String eventStateWord(Event event, DateTime now) {
  if (event.isDraft) return 'ciornă';
  if (event.isStopped) return 'oprit';
  if (event.isOverAt(now)) return 'încheiat';
  final start = event.dateEvent;
  if (start != null && !now.isBefore(start)) return 'în desfășurare';
  return 'publicat';
}

/// "Nicio echipă înscrisă", "O echipă înscrisă", "12 echipe înscrise".
String registeredTeamsCount(int teams) => switch (teams) {
      <= 0 => 'Nicio echipă înscrisă',
      1 => 'O echipă înscrisă',
      _ => '${_many(teams, 'echipe')} înscrise',
    };

/// The line under the event's name in the sheet: "12 echipe înscrise · publicat".
String eventMenuHeadline(Event event, int teams, DateTime now) =>
    '${registeredTeamsCount(teams)} · ${eventStateWord(event, now)}';

/// "Echipe înscrise" subtitle: "12 echipe · 46 jucători", "O echipă · un jucător".
String registeredTeamsLine(int teams, int players) {
  if (teams <= 0) return 'Nicio echipă încă';
  final teamText = teams == 1 ? 'O echipă' : _many(teams, 'echipe');
  final playerText = switch (players) {
    <= 0 => 'niciun jucător',
    1 => 'un jucător',
    _ => _many(players, 'jucători'),
  };
  return '$teamText · $playerText';
}

/// Everyone in the teams, counting old teams by the names they typed.
int playersOf(List<Team> teams) => teams.fold(0, (sum, team) => sum + team.memberList.length);

/// Teams whose latest message the organiser has not read.
int unreadConversations(List<Team> teams) => teams.where((team) => team.unreadText != null).length;
