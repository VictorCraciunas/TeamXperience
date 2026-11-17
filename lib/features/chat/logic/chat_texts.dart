import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/live_room/logic/live_texts.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/team.dart';

/// The chat's texts, worked out from plain values.

/// A team message without a signature (sent before the chat redesign).
const String unsignedSender = 'Echipa';
const String organiserLabel = 'Organizator';

/// "HH:MM".
String clockTime(DateTime at) => '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

/// Who wrote [message], as written above its bubble. The organiser sees the
/// captain marked ("Ana · căpitan"); a player sees the organiser as
/// "Organizator" and teammates by first name.
String senderLabel(Message message, Team team, {required bool organiserView}) {
  if (message.sender == Role.ADMIN) return organiserLabel;
  final name = message.senderName?.trim() ?? '';
  if (name.isEmpty) return unsignedSender;
  final uid = message.senderUid;
  final captain = organiserView && uid != null && uid == team.captainUid;
  return captain ? '$name · căpitan' : name;
}

/// Two letters for a player's avatar: the member's own initials, else from
/// the name ("Ioana Dima" → "ID", "Mihai" → "MI"), else the team's initial.
String senderInitials(Message message, Team team) {
  final uid = message.senderUid;
  if (uid != null) {
    for (final member in team.members) {
      if (member.uid == uid && member.initials.trim().isNotEmpty) return member.initials.trim().toUpperCase();
    }
  }
  final words = (message.senderName ?? '').trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return teamInitial(team.name);
  if (words.length > 1) {
    return (String.fromCharCode(words[0].runes.first) + String.fromCharCode(words[1].runes.first)).toUpperCase();
  }
  return String.fromCharCodes(words[0].runes.take(2)).toUpperCase();
}

/// The pill on a photo puzzle's picture.
String photoStatusLabel(PhotoApprovalStatus status) => switch (status) {
      PhotoApprovalStatus.pending => 'De aprobat',
      PhotoApprovalStatus.approved => 'Aprobată',
      PhotoApprovalStatus.denied => 'Respinsă',
    };

/// The mission and puzzle a photo's key names ("2_1_…" → misiunea 3,
/// puzzle 2), counted from one; null for anything else.
({int mission, int puzzle})? photoPlace(String? approvalKey) {
  final parts = (approvalKey ?? '').split('_');
  if (parts.length < 2) return null;
  final mission = int.tryParse(parts[0]);
  final puzzle = int.tryParse(parts[1]);
  if (mission == null || puzzle == null || mission < 0 || puzzle < 0) return null;
  return (mission: mission + 1, puzzle: puzzle + 1);
}

/// The members' first names, "Ana, Radu, Mihai"; empty without members.
String membersLine(Team team) => team.memberList
    .map((m) => m.displayName.trim().split(RegExp(r'\s+')).first)
    .where((name) => name.isNotEmpty)
    .join(', ');

/// "Moștenirea Cartografului · Lupii de Cetate", or the team alone while the
/// event's name is unknown.
String playerSubtitle(String? eventName, String teamName) {
  final event = eventName?.trim() ?? '';
  return event.isEmpty ? teamName : '$event · $teamName';
}

/// The organiser's strip: the text, how many bars are done and which one is
/// the current mission (null when none is: not started or finished). Null
/// for an event without missions.
({String text, int done, int? current})? missionStrip(Team team, int total) {
  if (total <= 0) return null;
  final done = team.missionProgress.clamp(0, total);
  if (team.hasFinished || team.missionProgress >= total) {
    return (text: 'Au terminat · $total din $total', done: total, current: null);
  }
  if (!team.hasStarted) return (text: 'N-au pornit încă', done: done, current: null);
  return (text: 'Misiunea ${done + 1} din $total', done: done, current: done);
}
