import '../enums/role.dart';

class AppUser {
  final String email;
  final String firstName;
  final String lastName;
  final String uid;
  final Role role;
  final List<String> registeredEventIds;
  final String fcmToken;


  AppUser({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.uid,
    this.role = Role.USER,
    List<String>? registeredEventIds,
    required this.fcmToken
  }) : registeredEventIds = registeredEventIds ?? [];

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
        fcmToken: data["fcmToken"] as String? ?? ""
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