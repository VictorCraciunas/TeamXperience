import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/model/message.dart';

import '../logic/chat_key.dart';
import '../logic/chat_to_open.dart' as pick;
import '../logic/first_watch.dart';
import '../logic/unread.dart';
import '../logic/watched_chat.dart';
import '../service/chat_seen_store.dart';

typedef ChatMessages = Stream<List<Message>> Function(ChatKey chat);

/// The player's unread organiser messages across their teams' chats, for the
/// floating chat button. Seen times are kept on this phone ([ChatSeenStore]);
/// a chat counts as read while it is the page on top ([chatOnTop]).
class ChatButtonController extends ChangeNotifier {
  ChatButtonController({
    required ChatMessages messages,
    required ChatSeenStore store,
    DateTime Function()? now,
    this.previewFor = const Duration(seconds: 6),
  })  : _messages = messages,
        _store = store,
        _now = now ?? DateTime.now;

  final ChatMessages _messages;
  final ChatSeenStore _store;
  final DateTime Function() _now;

  /// How long a new message's preview stays above the button.
  final Duration previewFor;

  final Map<ChatKey, _Watch> _watches = {};
  ChatKey? _onTop;
  ChatPreview? _preview;
  Timer? _previewTimer;
  bool _disposed = false;

  Iterable<pick.ChatUnread> get _unread => _watches.values.map((w) => w.unread);

  /// Organiser messages not read yet, in every watched chat.
  int get unread => pick.totalUnread(_unread);

  /// The chat with the newest unread message.
  WatchedChat? get chatToOpen {
    final key = pick.chatToOpen(_unread);
    return key == null ? null : _watches[key]?.chat;
  }

  /// A message that just arrived, while it is shown.
  ChatPreview? get preview => _preview;

  /// The chats to watch now: the player's team in each event not over.
  void watch(List<WatchedChat> chats) {
    if (_disposed) return;
    final wanted = {for (final chat in chats) chat.key: chat};
    var changed = false;
    for (final key in _watches.keys.toList()) {
      if (wanted.containsKey(key)) continue;
      _watches.remove(key)?.cancel();
      if (_preview?.chat.key == key) _clearPreview();
      changed = true;
    }
    for (final entry in wanted.entries) {
      final existing = _watches[entry.key];
      if (existing != null) {
        existing.chat = entry.value;
        continue;
      }
      final watch = _Watch(entry.value);
      _watches[entry.key] = watch;
      unawaited(_start(watch));
    }
    if (changed) _notify();
  }

  Future<void> _start(_Watch watch) async {
    DateTime seen;
    try {
      seen = await seenOrStart(_store, watch.key, _now());
    } catch (_) {
      seen = _now();
    }
    if (watch.cancelled) return;
    final marked = watch.seen;
    watch.seen = marked != null && marked.isAfter(seen) ? marked : seen;
    watch.sub = _messages(watch.key).listen((list) => _onMessages(watch, list), onError: (Object _) {});
  }

  void _onMessages(_Watch watch, List<Message> messages) {
    if (watch.cancelled) return;
    watch.messages = messages;
    final seen = watch.seen;
    if (_onTop == watch.key) {
      _markSeen(watch);
    } else if (watch.loaded && seen != null) {
      final fresh = freshOrganiserMessage(messages, seen, watch.lastKnown);
      if (fresh != null) _showPreview(ChatPreview(watch.chat, fresh));
    }
    final newest = newestOrganiserAt(messages);
    final known = watch.lastKnown;
    if (newest != null && (known == null || newest.isAfter(known))) watch.lastKnown = newest;
    watch.loaded = true;
    _notify();
  }

  /// The chat shown by the page on top of the app, or null for any other
  /// page. It is read while it stays there, and up to the moment it is left.
  void chatOnTop(ChatKey? chat) {
    if (_disposed || chat == _onTop) return;
    final left = _onTop;
    _onTop = chat;
    final leftWatch = left == null ? null : _watches[left];
    if (leftWatch != null) _markSeen(leftWatch);
    final shown = chat == null ? null : _watches[chat];
    if (shown != null) _markSeen(shown);
    if (chat != null && _preview?.chat.key == chat) _clearPreview();
    _notify();
  }

  void _markSeen(_Watch watch) {
    final previous = watch.seen;
    final next = seenAfterViewing(watch.messages, _now(), previous);
    if (previous != null && !next.isAfter(previous)) return;
    watch.seen = next;
    _store.write(watch.key, next).catchError((Object _) {});
  }

  void _showPreview(ChatPreview preview) {
    _previewTimer?.cancel();
    _preview = preview;
    _previewTimer = Timer(previewFor, () {
      _clearPreview();
      _notify();
    });
  }

  void _clearPreview() {
    _previewTimer?.cancel();
    _previewTimer = null;
    _preview = null;
  }

  void dismissPreview() {
    if (_preview == null) return;
    _clearPreview();
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _clearPreview();
    for (final watch in _watches.values) {
      watch.cancel();
    }
    _watches.clear();
    super.dispose();
  }
}

class _Watch {
  _Watch(this.chat);

  WatchedChat chat;
  DateTime? seen;
  List<Message> messages = const [];

  /// The first snapshot has come: messages after it are new arrivals.
  bool loaded = false;

  /// The newest organiser message seen in any snapshot so far.
  DateTime? lastKnown;
  StreamSubscription<List<Message>>? sub;
  bool cancelled = false;

  ChatKey get key => chat.key;

  pick.ChatUnread get unread {
    final at = seen;
    if (at == null) return pick.ChatUnread(key, 0, null);
    return pick.ChatUnread(key, unreadCount(messages, at), newestOrganiserAt(messages));
  }

  void cancel() {
    cancelled = true;
    sub?.cancel();
  }
}
