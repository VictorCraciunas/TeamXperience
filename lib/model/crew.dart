import 'crew_stats.dart';
import 'crew_team.dart';
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

  /// Its teams, oldest sign-up first (the functions append each new one).
  final List<CrewTeam> teams;

  const Crew({
    required this.id,
    required this.name,
    required this.captainUid,
    required this.memberUids,
    required this.members,
    required this.inviteCode,
    this.stats = const CrewStats(),
    this.teams = const [],
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
      teams: [
        for (final raw in map['teams'] as List<dynamic>? ?? const [])
          if (CrewTeam.fromMap(raw) case final team?) team,
      ],
    );
  }

  /// "VLP482" becomes "VLP-482".
  String get displayCode => invite_code.displayCode(inviteCode);

  /// The team it signed up last for an event other than [eventId]; null when
  /// it has none.
  CrewTeam? lastTeamExcept(String eventId) {
    for (final team in teams.reversed) {
      if (team.eventId != eventId) return team;
    }
    return null;
  }

  TeamMember? get captain {
    for (final member in members) {
      if (member.uid == captainUid) return member;
    }
    return null;
  }
}
