import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/model/message.dart';

/// Messages the organiser wrote, announcements included.
bool isFromOrganiser(Message message) => message.sender == Role.ADMIN;

/// The organiser's messages written after [seen].
int unreadCount(List<Message> messages, DateTime seen) =>
    messages.where((m) => isFromOrganiser(m) && m.timestamp.isAfter(seen)).length;

/// When the organiser's newest message was written, if there is one.
DateTime? newestOrganiserAt(List<Message> messages) {
  DateTime? newest;
  for (final m in messages) {
    if (!isFromOrganiser(m)) continue;
    if (newest == null || m.timestamp.isAfter(newest)) newest = m.timestamp;
  }
  return newest;
}

/// The seen time once [messages] have been on screen: up to the organiser's
/// newest message, never earlier than [previous]. Only the organiser's
/// messages move it: they are what unread counts, and a teammate whose phone
/// clock runs ahead would otherwise hide the organiser's next message. Not
/// [now] either, so an organiser phone running behind cannot hide one. A chat
/// with no organiser message keeps [previous], or is read up to [now] if it
/// has none.
DateTime seenAfterViewing(List<Message> messages, DateTime now, DateTime? previous) {
  final newest = newestOrganiserAt(messages);
  if (newest == null) return previous ?? now;
  if (previous != null && previous.isAfter(newest)) return previous;
  return newest;
}

/// The newest unread organiser message written after [lastKnown], the newest
/// one known before this snapshot (null: none known yet).
Message? freshOrganiserMessage(List<Message> messages, DateTime seen, DateTime? lastKnown) {
  Message? fresh;
  for (final m in messages) {
    if (!isFromOrganiser(m) || !m.timestamp.isAfter(seen)) continue;
    if (lastKnown != null && !m.timestamp.isAfter(lastKnown)) continue;
    if (fresh == null || m.timestamp.isAfter(fresh.timestamp)) fresh = m;
  }
  return fresh;
}
