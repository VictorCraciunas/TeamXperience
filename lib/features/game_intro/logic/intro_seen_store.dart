import 'package:shared_preferences/shared_preferences.dart';

/// Which teams have read their intro letter on this device, as
/// "eventId|teamName" entries (an event is played once).
class IntroSeenStore {
  static const _key = 'introSeen';

  static String _entry(String eventId, String teamName) => '$eventId|$teamName';

  Future<bool> seen(String eventId, String teamName) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).contains(_entry(eventId, teamName));
  }

  Future<void> markSeen(String eventId, String teamName) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = prefs.getStringList(_key) ?? <String>[];
    final entry = _entry(eventId, teamName);
    if (entries.contains(entry)) return;
    await prefs.setStringList(_key, [...entries, entry]);
  }
}
