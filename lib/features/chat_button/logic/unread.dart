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

/// The seen time once [messages] have been on screen: up to the newest of
/// them (whoever wrote it, so a message stamped by a phone whose clock runs
/// ahead is read too), [now] for an empty chat, never earlier than
/// [previous].
DateTime seenAfterViewing(List<Message> messages, DateTime now, DateTime? previous) {
  var seen = messages.isEmpty ? now : messages.first.timestamp;
  for (final m in messages) {
    if (m.timestamp.isAfter(seen)) seen = m.timestamp;
  }
  if (previous != null && previous.isAfter(seen)) return previous;
  return seen;
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
