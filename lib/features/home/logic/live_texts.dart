import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/service/leaderboard.dart';

/// How recently a member must have been seen to count as playing now.
const Duration activeWindow = Duration(minutes: 2);

/// "1:17:42"; never negative.
String liveClock(Duration left) {
  final total = left.isNegative ? Duration.zero : left;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${total.inHours}:${two(total.inMinutes.remainder(60))}:${two(total.inSeconds.remainder(60))}';
}

/// "Echipa Vulpile · misiunea 4 din 6", or just the team without missions.
String missionLine(Team team, int total) {
  if (total <= 0) return 'Echipa ${team.name}';
  final current = (team.missionProgress + 1).clamp(1, total);
  return 'Echipa ${team.name} · misiunea $current din $total';
}

/// The members seen playing in the last [activeWindow] (a time ahead of
/// [now], from another device's clock, counts as now).
List<TeamMember> activeMembers(Team team, DateTime now) {
  return [
    for (final member in team.memberList)
      if (team.presence[member.uid] case final seen? when now.difference(seen) <= activeWindow) member,
  ];
}

/// "3 jucători activi", "1 jucător activ", or "Niciun jucător activ acum".
String activeLine(int count) => switch (count) {
      0 => 'Niciun jucător activ acum',
      1 => '1 jucător activ',
      _ => '$count jucători activi',
    };

/// "Ultima misiune rezolvată acum 6 min" (or "acum câteva secunde",
/// "acum 2 h"), or "Nicio misiune rezolvată încă".
String lastMissionLine(DateTime? at, DateTime now) {
  if (at == null) return 'Nicio misiune rezolvată încă';
  final ago = now.difference(at);
  final when = switch (ago.inMinutes) {
    < 1 => 'câteva secunde',
    < 60 => '${ago.inMinutes} min',
    _ => '${ago.inHours} h',
  };
  return 'Ultima misiune rezolvată acum $when';
}

/// The rows of the Home leaderboard: the top three, or the top two and the
/// player's team when it is lower.
List<RankedTeam> leaderboardPreview(List<RankedTeam> ranked, String ownName) {
  final top = ranked.take(3).toList();
  if (top.any((r) => r.team.name == ownName)) return top;
  final own = ranked.where((r) => r.team.name == ownName).firstOrNull;
  if (own == null) return top;
  return [...ranked.take(2), own];
}
