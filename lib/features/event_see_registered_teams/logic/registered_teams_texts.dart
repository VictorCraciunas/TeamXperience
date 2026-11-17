import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'team_stats.dart';

/// How many members an open card lists before "+ N jucători".
const shownMembers = 3;

/// The line under a team's name, and whether it is in the warning colour.
class TeamSummary {
  const TeamSummary(this.text, {this.warning = false});

  final String text;
  final bool warning;
}

/// "1 jucător", "4 jucători", "20 de jucători".
String playersWord(int n) {
  if (n == 1) return '1 jucător';
  final rest = n % 100;
  final de = n != 0 && (rest == 0 || rest >= 20);
  return de ? '$n de jucători' : '$n jucători';
}

/// "Radu M." for "Radu Marin": the first name and the last name's initial.
String shortName(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length < 2) return words.join();
  return '${words.first} ${String.fromCharCode(words.last.runes.first).toUpperCase()}.';
}

/// "2 din 4 jucători · incompletă" (warning), "4 din 4 jucători · Căpitan:
/// Radu M." while closed, "5 din 5 jucători" while open (the captain is in
/// the member list then). A team without a size counts only who joined.
TeamSummary teamSummary(Team team, {required bool expanded}) {
  final joined = joinedCount(team);
  final count = team.numberOfMembers > 0 ? '$joined din ${playersWord(team.numberOfMembers)}' : playersWord(joined);
  if (isIncomplete(team)) return TeamSummary('$count · incompletă', warning: true);
  final captain = shortName(team.captainName);
  if (expanded || captain.isEmpty) return TeamSummary(count);
  return TeamSummary('$count · Căpitan: $captain');
}

/// "+ 2 jucători · 0722 123 456 · ana.pop@email.ro" under an open card's
/// members; the parts that are missing are left out, null when all are.
String? contactLine(Team team) {
  final more = team.memberList.length - shownMembers;
  final parts = [
    if (more > 0) '+ ${playersWord(more)}',
    team.phoneNumber.trim(),
    team.captainEmail.trim(),
  ].where((p) => p.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(' · ');
}

/// "Moștenirea Cartografului · Sâm 21 nov" under the page title, or whichever
/// of the two the event has; null with neither.
String? eventSubtitle(Event event) {
  final date = event.dateEvent;
  final parts = [
    (event.name ?? '').trim(),
    if (date != null) '${shortDay(date)} ${dayAndMonth(date)}',
  ].where((p) => p.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(' · ');
}
