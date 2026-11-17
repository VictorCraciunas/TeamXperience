import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/team.dart';

/// The newest message of a team's chat, as much as the list shows of it.
class LastMessage {
  const LastMessage({required this.fromOrganiser, required this.text, required this.isPhoto, required this.at});

  final bool fromOrganiser;
  final String text;
  final bool isPhoto;
  final DateTime at;
}

/// Which rows the list shows.
enum ChatFilter { all, unread }

/// One team's line in the organiser's list of conversations.
class ChatRow {
  const ChatRow({required this.team, this.last, this.lastLoaded = true});

  final Team team;

  /// Null when the chat has no message (or, while [lastLoaded] is false, when
  /// it has not been read yet).
  final LastMessage? last;
  final bool lastLoaded;

  Iterable<MapEntry<String, PhotoApprovalStatus>> get _pending =>
      team.photoApprovals.entries.where((e) => e.value == PhotoApprovalStatus.pending);

  /// The red count: messages the organiser has not read plus photos waiting
  /// for a decision.
  int get badge => team.unreadCount + _pending.length;

  bool get isUnread => badge > 0;

  /// The newest waiting photo's key, or null.
  String? get _newestPendingKey {
    String? key;
    DateTime? newest;
    for (final entry in _pending) {
      final at = team.photoDetails[entry.key]?.at;
      final best = newest;
      if (key == null || (at != null && (best == null || at.isAfter(best)))) {
        key = entry.key;
        newest = at;
      }
    }
    return key;
  }

  /// The mission (1 for the first) of the newest photo waiting, or null.
  int? get pendingPhotoMission {
    final key = _newestPendingKey;
    if (key == null) return null;
    final index = int.tryParse(key.split('_').first);
    return index == null ? null : index + 1;
  }

  /// The latest of the last message, the unread mark and a waiting photo;
  /// null for a chat with none of them.
  DateTime? get time {
    DateTime? latest;
    void consider(DateTime? at) {
      final current = latest;
      if (at != null && (current == null || at.isAfter(current))) latest = at;
    }

    consider(last?.at);
    consider(team.unreadAt);
    for (final entry in _pending) {
      consider(team.photoDetails[entry.key]?.at);
    }
    return latest;
  }
}

int _newestFirst(ChatRow a, ChatRow b) {
  final at = a.time;
  final bt = b.time;
  if (at != null && bt != null) {
    final byTime = bt.compareTo(at);
    if (byTime != 0) return byTime;
  } else if (at != null) {
    return -1;
  } else if (bt != null) {
    return 1;
  }
  return a.team.name.compareTo(b.team.name);
}

/// The rows with something to read, newest first, and the rest, by their
/// last message, newest first; chats with no message last. Ties by name.
({List<ChatRow> unread, List<ChatRow> read}) splitChatRows(List<ChatRow> rows) {
  final unread = [for (final row in rows) if (row.isUnread) row]..sort(_newestFirst);
  final read = [for (final row in rows) if (!row.isUnread) row]..sort(_newestFirst);
  return (unread: unread, read: read);
}
