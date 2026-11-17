import 'chat_key.dart';

/// How many organiser messages one chat has unread, and when the newest of
/// them was written.
class ChatUnread {
  const ChatUnread(this.chat, this.count, this.newest);

  final ChatKey chat;
  final int count;
  final DateTime? newest;
}

int totalUnread(Iterable<ChatUnread> chats) => chats.fold(0, (sum, c) => sum + c.count);

/// The chat with the newest unread message; null when everything is read.
ChatKey? chatToOpen(Iterable<ChatUnread> chats) {
  ChatUnread? best;
  for (final c in chats) {
    if (c.count <= 0) continue;
    final at = c.newest;
    final bestAt = best?.newest;
    if (best == null || (at != null && (bestAt == null || at.isAfter(bestAt)))) best = c;
  }
  return best?.chat;
}
