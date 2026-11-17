import 'package:shared_preferences/shared_preferences.dart';

/// The email of the account last signed in on this device, kept after logout
/// so the log-in form starts with it.
class LastEmailStore {
  static const _key = 'lastEmail';

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// A blank [email] changes nothing.
  Future<void> save(String email) async {
    final clean = email.trim();
    if (clean.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, clean);
  }
}
