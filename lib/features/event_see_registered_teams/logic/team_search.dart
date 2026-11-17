import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/utils/plain_text.dart';

/// [team]'s name, its captain or one of its members contains [query],
/// whatever the case and the diacritics. A blank query matches every team.
bool matchesSearch(Team team, String query) {
  final wanted = plainText(query.trim());
  if (wanted.isEmpty) return true;
  final names = [team.name, team.captainName, ...team.memberList.map((m) => m.displayName)];
  return names.any((name) => plainText(name).contains(wanted));
}
