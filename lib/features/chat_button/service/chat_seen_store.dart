import 'package:shared_preferences/shared_preferences.dart';

import '../logic/chat_key.dart';

/// When each team chat was last read on this phone.
abstract class ChatSeenStore {
  Future<DateTime?> read(ChatKey chat);
  Future<void> write(ChatKey chat, DateTime seen);
}

class SharedPrefsChatSeenStore implements ChatSeenStore {
  static String _key(ChatKey chat) => 'chatSeen|${chat.eventId}|${chat.teamName}';

  @override
  Future<DateTime?> read(ChatKey chat) async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_key(chat));
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  @override
  Future<void> write(ChatKey chat, DateTime seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key(chat), seen.millisecondsSinceEpoch);
  }
}
