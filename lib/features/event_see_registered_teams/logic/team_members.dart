import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/utils/event_formats.dart';
import 'package:teamxperience/utils/plain_text.dart';

/// One row of an open team card.
class MemberRow {
  const MemberRow(this.member, {required this.isCaptain});

  final TeamMember member;
  final bool isCaptain;
}

/// [team]'s members with the captain first. The captain is the member whose
/// uid is `captainUid`; a team without one (old data) is matched by
/// `captainName`.
List<MemberRow> orderedMembers(Team team) {
  final captainUid = team.captainUid;
  final captainName = plainText(team.captainName.trim());
  bool isCaptain(TeamMember m) {
    if (captainUid != null && captainUid.isNotEmpty) return m.uid == captainUid;
    return captainName.isNotEmpty && plainText(m.displayName.trim()) == captainName;
  }

  final rows = [for (final m in team.memberList) MemberRow(m, isCaptain: isCaptain(m))];
  final captainIndex = rows.indexWhere((r) => r.isCaptain);
  if (captainIndex > 0) rows.insert(0, rows.removeAt(captainIndex));
  return rows;
}

/// The stored initials, else made from the name; "?" for a nameless member.
String memberInitials(TeamMember member) {
  if (member.initials.trim().isNotEmpty) return member.initials.trim();
  final made = initialsOf(member.displayName);
  return made.isEmpty ? '?' : made;
}

/// "V" for "vulpile"; "?" for an empty name.
String teamInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}
