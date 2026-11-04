import 'package:teamxperience/model/team_member.dart';

/// The crew's next team in an event that isn't over.
class InviteEvent {
  final String eventId;
  final String name;
  final DateTime dateEvent;
  final String teamName;
  final int size;

  /// Players already in the team.
  final int count;

  const InviteEvent({
    required this.eventId,
    required this.name,
    required this.dateEvent,
    required this.teamName,
    required this.size,
    required this.count,
  });

  factory InviteEvent.fromMap(Map<String, dynamic> map) {
    return InviteEvent(
      eventId: map['eventId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      dateEvent: DateTime.tryParse(map['dateEvent'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      teamName: map['teamName'] as String? ?? '',
      size: (map['size'] as num?)?.toInt() ?? 0,
      count: (map['count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// What `previewInvite` returns: who is behind a code, before joining.
class InvitePreview {
  final String crewId;
  final String crewName;
  final String captainName;
  final List<TeamMember> members;
  final bool alreadyMember;
  final InviteEvent? event;

  const InvitePreview({
    required this.crewId,
    required this.crewName,
    required this.captainName,
    required this.members,
    required this.alreadyMember,
    this.event,
  });

  factory InvitePreview.fromMap(Map<String, dynamic> map) {
    final rawMembers = map['members'] as List<dynamic>? ?? [];
    final rawEvent = map['event'];
    return InvitePreview(
      crewId: map['crewId'] as String? ?? '',
      crewName: map['crewName'] as String? ?? '',
      captainName: map['captainName'] as String? ?? '',
      members: rawMembers
          .whereType<Map>()
          .map((m) => TeamMember.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
      alreadyMember: map['alreadyMember'] as bool? ?? false,
      event: rawEvent is Map
          ? InviteEvent.fromMap(Map<String, dynamic>.from(rawEvent))
          : null,
    );
  }

  /// "1 din 4 · tu ești al 2-lea"; null when the crew has no upcoming team.
  String? get slotLine {
    final e = event;
    if (e == null) return null;
    final place = e.count == 0 ? 'primul' : 'al ${e.count + 1}-lea';
    return '${e.count} din ${e.size} · tu ești $place';
  }

  bool get isFull {
    final e = event;
    return e != null && e.count >= e.size;
  }
}
