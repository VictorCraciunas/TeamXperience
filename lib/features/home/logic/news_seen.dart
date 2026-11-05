import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamxperience/model/stire.dart';

/// Whether any news item was published after [lastSeen] (any news at all
/// when the player never opened Știri).
bool hasUnreadNews(List<Stire> news, DateTime? lastSeen) {
  for (final item in news) {
    final at = item.publicationDate;
    if (at == null) continue;
    if (lastSeen == null || at.isAfter(lastSeen)) return true;
  }
  return false;
}

/// When the player last opened Știri, kept on this device only.
class NewsSeenStore {
  static const _key = 'newsLastSeen';

  Future<DateTime?> lastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_key);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> markSeen(DateTime at) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, at.millisecondsSinceEpoch);
  }
}
