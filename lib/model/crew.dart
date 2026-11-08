import 'crew_stats.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/utils/invite_code.dart' as invite_code;

/// A group of players that lasts across events. Written by Cloud Functions.
class Crew {
  final String id;
  final String name;
  final String captainUid;
  final List<String> memberUids;
  final List<TeamMember> members;

  /// Stored without the dash, upper-case: "VLP482".
  final String inviteCode;

  /// What the crew has done together; zeros until its first results.
  final CrewStats stats;

  const Crew({
    required this.id,
    required this.name,
    required this.captainUid,
    required this.memberUids,
    required this.members,
    required this.inviteCode,
    this.stats = const CrewStats(),
  });

  factory Crew.fromMap(String id, Map<String, dynamic> map) {
    final rawUids = map['memberUids'] as List<dynamic>? ?? [];
    final rawMembers = map['members'] as List<dynamic>? ?? [];
    return Crew(
      id: id,
      name: map['name'] as String? ?? '',
      captainUid: map['captainUid'] as String? ?? '',
      memberUids: rawUids.map((uid) => uid.toString()).toList(),
      members: rawMembers
          .whereType<Map>()
          .map((m) => TeamMember.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
      inviteCode: map['inviteCode'] as String? ?? '',
      stats: CrewStats.fromMap(map['stats']),
    );
  }

  /// "VLP482" becomes "VLP-482".
  String get displayCode => invite_code.displayCode(inviteCode);

  TeamMember? get captain {
    for (final member in members) {
      if (member.uid == captainUid) return member;
    }
    return null;
  }
}
