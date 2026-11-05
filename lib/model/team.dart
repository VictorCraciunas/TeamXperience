import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/utils/invite_code.dart' as invite_code;

class Team {
  final String name;
  final String teamMembers;
  final String captainName;
  final String phoneNumber;
  final String captainEmail;
  int missionProgress;
  int puzzleNumber;
  List<String> userIds;
  bool hasStarted;
  bool hasFinished;
  double latitude;
  double longitude;
  int numberOfMembers;
  Map<String, PhotoApprovalStatus> photoApprovals;
  final String? crewId;
  final String? captainUid;
  final List<TeamMember> members;

  /// Stored without the dash, upper-case: "VLP482".
  final String? inviteCode;
  final bool photoConsent;

  /// When each member was last seen playing (uid → time), written by the game
  /// screen every minute. Never written by [toJson].
  final Map<String, DateTime> presence;

  /// When the first member entered the start code (server time); the game's
  /// clock. Set once by `TeamRepo.startTeam`; never written by [toJson].
  final DateTime? startedAt;

  /// When each mission was solved (mission index → time). Never written by
  /// [toJson]: the puzzle controller sets one entry at a time.
  final Map<int, DateTime> missionCompletedAt;

  Team({
    required this.name,
    required this.teamMembers,
    required this.captainName,
    required this.phoneNumber,
    required this.captainEmail,
    this.missionProgress = 0,
    this.puzzleNumber = 0,
    List<String>? userIds,
    this.hasStarted = false,
    this.hasFinished = false,
    this.latitude = 0,
    this.longitude = 0,
    this.numberOfMembers = 0,
    Map<String, PhotoApprovalStatus>? photoApprovals,
    this.crewId,
    this.captainUid,
    this.members = const [],
    this.inviteCode,
    this.photoConsent = false,
    Map<String, DateTime>? presence,
    Map<int, DateTime>? missionCompletedAt,
    this.startedAt,
  })  : userIds = userIds ?? [],
        photoApprovals = photoApprovals ?? {},
        presence = presence ?? {},
        missionCompletedAt = missionCompletedAt ?? {};

  /// The time the latest mission was solved, or null before the first.
  DateTime? get lastMissionAt {
    DateTime? latest;
    for (final at in missionCompletedAt.values) {
      final current = latest;
      if (current == null || at.isAfter(current)) latest = at;
    }
    return latest;
  }

  /// A Timestamp (or DateTime) as a DateTime; null for a pending server
  /// timestamp or anything else.
  static DateTime? _time(Object? value) => switch (value) {
        Timestamp() => value.toDate(),
        DateTime() => value,
        _ => null,
      };

  static Map<String, DateTime> _presence(Object? raw) {
    final result = <String, DateTime>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        final at = _time(value);
        if (at != null) result[key.toString()] = at;
      });
    }
    return result;
  }

  static Map<int, DateTime> _missionTimes(Object? raw) {
    final result = <int, DateTime>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        final index = int.tryParse(key.toString());
        final at = _time(value);
        if (index != null && at != null) result[index] = at;
      });
    }
    return result;
  }

  /// "VLP-482", or null for a team without an invite code.
  String? get displayCode {
    final code = inviteCode;
    return code == null ? null : invite_code.displayCode(code);
  }

  /// The members, or for old teams the names typed in `teamMembers`.
  List<TeamMember> get memberList {
    if (members.isNotEmpty) return members;
    return teamMembers
        .split(',')
        .where((name) => name.trim().isNotEmpty)
        .map(TeamMember.fromName)
        .toList();
  }

  static String approvalKeyPrefix(int missionIndex, int puzzleIndex) =>
      '${missionIndex}_${puzzleIndex}_';

  static String approvalKey(int missionIndex, int puzzleIndex, int tryIndex) =>
      '${missionIndex}_${puzzleIndex}_$tryIndex';

  int nextTryIndex(int missionIndex, int puzzleIndex) {
    final prefix = approvalKeyPrefix(missionIndex, puzzleIndex);
    return photoApprovals.keys.where((k) => k.startsWith(prefix)).length;
  }

  bool isPuzzleApproved(int missionIndex, int puzzleIndex) {
    final prefix = approvalKeyPrefix(missionIndex, puzzleIndex);
    return photoApprovals.entries
        .any((e) => e.key.startsWith(prefix) && e.value == PhotoApprovalStatus.approved);
  }

  String? pendingKeyForPuzzle(int missionIndex, int puzzleIndex) {
    final prefix = approvalKeyPrefix(missionIndex, puzzleIndex);
    for (final entry in photoApprovals.entries) {
      if (entry.key.startsWith(prefix) && entry.value == PhotoApprovalStatus.pending) {
        return entry.key;
      }
    }
    return null;
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    final rawUserIds = map['userIds'] as List<dynamic>? ?? [];
    final userIdsList = rawUserIds.map((id) => id.toString()).toList();

    final rawApprovals = map['photoApprovals'] as Map<String, dynamic>? ?? {};
    final approvals = <String, PhotoApprovalStatus>{};
    rawApprovals.forEach((k, v) {
      final name = v.toString();
      final status = PhotoApprovalStatus.values
          .where((s) => s.name == name)
          .firstOrNull;
      if (status != null) approvals[k] = status;
    });

    final rawMembers = map['members'] as List<dynamic>? ?? [];
    final membersList = rawMembers
        .whereType<Map>()
        .map((m) => TeamMember.fromMap(Map<String, dynamic>.from(m)))
        .toList();

    return Team(
      name: map['name'] as String? ?? '',
      teamMembers: map['teamMembers'] as String? ?? '',
      captainName: map['captainName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      captainEmail: map['captainEmail'] as String? ?? '',
      missionProgress: map['missionProgress'] as int? ?? 0,
      puzzleNumber: map['puzzleNumber'] as int? ?? 0,
      userIds: userIdsList,
      hasStarted: map['hasStarted'] as bool? ?? false,
      hasFinished: map['hasFinished'] as bool? ?? false,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      numberOfMembers: map['numberOfMembers'] as int? ?? 0,
      photoApprovals: approvals,
      crewId: map['crewId'] as String?,
      captainUid: map['captainUid'] as String?,
      members: membersList,
      inviteCode: map['inviteCode'] as String?,
      photoConsent: map['photoConsent'] as bool? ?? false,
      presence: _presence(map['presence']),
      missionCompletedAt: _missionTimes(map['missionCompletedAt']),
      startedAt: _time(map['startedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'teamMembers': teamMembers,
      'captainName': captainName,
      'phoneNumber': phoneNumber,
      'captainEmail': captainEmail,
      'missionProgress': missionProgress,
      'puzzleNumber': puzzleNumber,
      'userIds': userIds,
      'hasStarted': hasStarted,
      'hasFinished': hasFinished,
      'latitude': latitude,
      'longitude': longitude,
      'numberOfMembers': numberOfMembers,
      'photoApprovals': photoApprovals.map((k, v) => MapEntry(k, v.name)),
      if (crewId != null) 'crewId': crewId,
      if (captainUid != null) 'captainUid': captainUid,
      'members': members.map((m) => m.toJson()).toList(),
      if (inviteCode != null) 'inviteCode': inviteCode,
      'photoConsent': photoConsent,
    };
  }

}
