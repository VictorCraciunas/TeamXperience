import '../enums/role.dart';

class AppUser {
  final String email;
  final String firstName;
  final String lastName;
  final String uid;
  final Role role;

  AppUser({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.uid,
    this.role = Role.USER,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    final raw = data['role'] as String? ?? Role.USER.name;
    final role = Role.values.byName(raw);

    return AppUser(
      email: data["email"] ?? "",
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      uid: data["uid"] ?? "",
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "firstName": firstName, "lastName":lastName, "uid": uid, "role": role.name};
  }
}
