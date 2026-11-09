import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/photo_detail.dart';
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

  /// Everything stored for each photo try: status, reason, picture, time.
  final Map<String, PhotoDetail> photoDetails;
  final String? crewId;
  final String? captainUid;
  final List<TeamMember> members;

  /// Stored without the dash, upper-case: "VLP482".
  final String? inviteCode;
  final bool photoConsent;

  /// The team's optional photo from before the game, and from after it.
  /// Set one at a time by `TeamRepo.setTeamPhoto`; never written by [toJson].
  final String? startPhotoUrl;
  final String? finishPhotoUrl;

  /// When each member was last seen playing (uid → time), written by the game
  /// screen every minute. Never written by [toJson].
  final Map<String, DateTime> presence;

  /// When the first member entered the start code (server time); the game's
  /// clock. Set once by `TeamRepo.startTeam`; never written by [toJson].
  final DateTime? startedAt;

  /// When the team solved its last mission (server time); null when the
  /// event ended first. Set once by `TeamRepo.finishTeam`; never written by
  /// [toJson].
  final DateTime? finishedAt;

  /// How far each phone walked (uid → metres), each phone adding its own.
  /// Never written by [toJson].
  final Map<String, double> walked;

  /// The team's walk: the longest of its phones' (they walk together).
  double get distanceMeters => walked.values.fold(0.0, (longest, m) => m > longest ? m : longest);

  /// When each mission was solved (mission index → time). Never written by
  /// [toJson]: the puzzle controller sets one entry at a time.
  final Map<int, DateTime> missionCompletedAt;

  /// Wrong answers per puzzle ([puzzleKey] → count), shared by the team's
  /// phones through increments. Never written by [toJson].
  final Map<String, int> attempts;

  /// The puzzles whose hint the team opened. Never written by [toJson].
  final Map<String, bool> hintsUsed;

  /// Until when a puzzle refuses answers after its attempts ran out. Never
  /// written by [toJson].
  final Map<String, DateTime> lockedUntil;

  /// The team's latest message the organiser has not read, stored with
  /// [unreadAt] under `unreadByAdmin`: the player's send sets it, opening the
  /// chat as organiser clears it. Never written by [toJson].
  final String? unreadText;

  /// When [unreadText] was sent; null while the server time is on its way.
  final DateTime? unreadAt;

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
    Map<String, PhotoDetail>? photoDetails,
    this.crewId,
    this.captainUid,
    this.members = const [],
    this.inviteCode,
    this.photoConsent = false,
    this.startPhotoUrl,
    this.finishPhotoUrl,
    Map<String, DateTime>? presence,
    Map<int, DateTime>? missionCompletedAt,
    this.startedAt,
    this.finishedAt,
    Map<String, double>? walked,
    Map<String, int>? attempts,
    Map<String, bool>? hintsUsed,
    Map<String, DateTime>? lockedUntil,
    this.unreadText,
    this.unreadAt,
  })  : userIds = userIds ?? [],
        photoApprovals = photoApprovals ?? {},
        photoDetails = photoDetails ?? {},
        presence = presence ?? {},
        missionCompletedAt = missionCompletedAt ?? {},
        attempts = attempts ?? {},
        hintsUsed = hintsUsed ?? {},
        lockedUntil = lockedUntil ?? {},
        walked = walked ?? {};

  /// The key of one puzzle in [attempts], [hintsUsed] and [lockedUntil]: "3_0".
  static String puzzleKey(int mission, int puzzle) => '${mission}_$puzzle';

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

  static Map<String, DateTime> _timesByKey(Object? raw) {
    final result = <String, DateTime>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        final at = _time(value);
        if (at != null) result[key.toString()] = at;
      });
    }
    return result;
  }

  static Map<String, int> _counts(Object? raw) {
    final result = <String, int>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is num && value == value.roundToDouble()) result[key.toString()] = value.toInt();
      });
    }
    return result;
  }

  static Map<String, double> _meters(Object? raw) {
    final result = <String, double>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is num) result[key.toString()] = value.toDouble();
      });
    }
    return result;
  }

  static Map<String, bool> _flags(Object? raw) {
    final result = <String, bool>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value == true) result[key.toString()] = true;
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

  /// One slot's picture from `teamPhotos`, whatever old or bad data it holds.
  static String? _teamPhotoUrl(Object? photos, String slot) {
    if (photos is! Map) return null;
    final photo = photos[slot];
    if (photo is! Map) return null;
    final url = photo['url'];
    return url is String ? url : null;
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    final rawUserIds = map['userIds'] as List<dynamic>? ?? [];
    final userIdsList = rawUserIds.map((id) => id.toString()).toList();

    final rawApprovals = map['photoApprovals'];
    final approvals = <String, PhotoApprovalStatus>{};
    final details = <String, PhotoDetail>{};
    if (rawApprovals is Map) {
      rawApprovals.forEach((k, v) {
        final detail = PhotoDetail.fromValue(v);
        if (detail == null) return;
        approvals[k.toString()] = detail.status;
        details[k.toString()] = detail;
      });
    }

    final rawUnread = map['unreadByAdmin'];
    final unread = rawUnread is Map ? rawUnread : const {};
    final unreadText = unread['text'];

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
      photoDetails: details,
      crewId: map['crewId'] as String?,
      captainUid: map['captainUid'] as String?,
      members: membersList,
      inviteCode: map['inviteCode'] as String?,
      photoConsent: map['photoConsent'] as bool? ?? false,
      startPhotoUrl: _teamPhotoUrl(map['teamPhotos'], 'start'),
      finishPhotoUrl: _teamPhotoUrl(map['teamPhotos'], 'finish'),
      presence: _timesByKey(map['presence']),
      missionCompletedAt: _missionTimes(map['missionCompletedAt']),
      startedAt: _time(map['startedAt']),
      finishedAt: _time(map['finishedAt']),
      walked: _meters(map['walked']),
      attempts: _counts(map['attempts']),
      hintsUsed: _flags(map['hintsUsed']),
      lockedUntil: _timesByKey(map['lockedUntil']),
      unreadText: unreadText is String ? unreadText : null,
      unreadAt: _time(unread['at']),
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
      'photoApprovals': photoApprovals.map(
        (k, v) => MapEntry(k, (photoDetails[k] ?? PhotoDetail(status: v)).toJson()),
      ),
      if (crewId != null) 'crewId': crewId,
      if (captainUid != null) 'captainUid': captainUid,
      'members': members.map((m) => m.toJson()).toList(),
      if (inviteCode != null) 'inviteCode': inviteCode,
      'photoConsent': photoConsent,
    };
  }

}
