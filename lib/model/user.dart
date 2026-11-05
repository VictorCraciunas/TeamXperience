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
  }) : registeredEventIds = registeredEventIds ?? [];

  AppUser copyWith({List<String>? registeredEventIds, String? fcmToken}) {
    return AppUser(
      email: email,
      firstName: firstName,
      lastName: lastName,
      uid: uid,
      role: role,
      registeredEventIds: registeredEventIds ?? this.registeredEventIds,
      fcmToken: fcmToken ?? this.fcmToken,
      xp: xp,
      stats: stats,
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
        xp: (data['xp'] as num?)?.toInt() ?? 0,
        stats: UserStats.fromMap(data['stats']),
    );
  }

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