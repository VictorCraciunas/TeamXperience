import '../enums/role.dart';
import 'user_stats.dart';

class AppUser {
  final String email;
  final String firstName;
  final String lastName;
  final String uid;
  final Role role;
  final List<String> registeredEventIds;
  final String fcmToken;

  /// Experience points, written by the end-of-event function (step 7).
  final int xp;
  final UserStats stats;

  /// The ids of the badges earned (see `badge_catalog.dart`), written by the
  /// end-of-event function.
  final List<String> badges;

  AppUser({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.uid,
    this.role = Role.USER,
    List<String>? registeredEventIds,
    required this.fcmToken,
    this.xp = 0,
    this.stats = const UserStats(),
    this.badges = const [],
  }) : registeredEventIds = registeredEventIds ?? [];

  AppUser copyWith({
    List<String>? registeredEventIds,
    String? fcmToken,
    int? xp,
    UserStats? stats,
    List<String>? badges,
  }) {
    return AppUser(
      email: email,
      firstName: firstName,
      lastName: lastName,
      uid: uid,
      role: role,
      registeredEventIds: registeredEventIds ?? this.registeredEventIds,
      fcmToken: fcmToken ?? this.fcmToken,
      xp: xp ?? this.xp,
      stats: stats ?? this.stats,
      badges: badges ?? this.badges,
    );
  }

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    final raw = data['role'] as String? ?? Role.USER.name;
    final role = Role.values.byName(raw);
    final rawEventIds = data['registeredEventIds'] as List<dynamic>? ?? [];
    final eventIds = rawEventIds.map((id) => id.toString()).toList();

    return AppUser(
        email: data["email"] ?? "",
        firstName: data['firstName'] as String,
        lastName: data['lastName'] as String,
        uid: data["uid"] ?? "",
        role: role,
        registeredEventIds: eventIds,
        fcmToken: data["fcmToken"] as String? ?? "",
        xp: readCount(data['xp']),
        stats: UserStats.fromMap(data['stats']),
        badges: _ids(data['badges']),
    );
  }

  static List<String> _ids(Object? raw) => raw is List ? [for (final id in raw) if (id is String) id] : const [];

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "uid": uid,
      "role": role.name,
      "registeredEventIds": registeredEventIds,
      "fcmToken":fcmToken
    };
  }

  bool isRegisterToEvent(String eventId){
    return registeredEventIds.contains(eventId);
  }
}