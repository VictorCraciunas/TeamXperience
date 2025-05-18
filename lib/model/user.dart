import '../enums/role.dart';

class AppUser {
  final String email;
  final String uid;
  final Role role;

  AppUser({required this.email, required this.uid, this.role = Role.USER});

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    final raw = data['role'] as String? ?? Role.USER.name;
    final role = Role.values.byName(raw);

    return AppUser(
      email: data["email"] ?? "",
      uid: data["uid"] ?? "",
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "uid": uid, "role": role.name};
  }
}
