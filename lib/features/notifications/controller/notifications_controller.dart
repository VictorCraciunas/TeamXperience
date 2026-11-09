import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/model/app_notification.dart';

/// The Notificări page: follows the player's list and marks rows read. A
/// mark that fails is ignored: the row only stays unread.
class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required Stream<List<AppNotification>> stream,
    required Future<void> Function(String id) markRead,
    required Future<void> Function(Iterable<String> ids) markAllRead,
  })  : _markRead = markRead,
        _markAllRead = markAllRead {
    _watch = stream.listen((value) {
      _items = value;
      _loading = false;
      _failed = false;
      _changed();
    }, onError: (Object _) {
      _loading = false;
      _failed = true;
      _changed();
    });
  }

  final Future<void> Function(String id) _markRead;
  final Future<void> Function(Iterable<String> ids) _markAllRead;
  late final StreamSubscription<List<AppNotification>> _watch;
  bool _disposed = false;

  List<AppNotification> _items = const [];
  bool _loading = true;
  bool _failed = false;

  List<AppNotification> get items => _items;
  bool get loading => _loading;
  bool get failed => _failed;
  bool get hasUnread => _items.any((n) => !n.read);

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  /// Marks [n] read, if it was not, without waiting: offline the write is
  /// only confirmed later, and the tap must open its page at once.
  Future<void> open(AppNotification n) async {
    if (n.read) return;
    unawaited(_markRead(n.id).catchError((Object _) {}));
  }

  /// Marks every unread row read, without waiting for the server either.
  Future<void> markAll() async {
    final unread = [for (final n in _items) if (!n.read) n.id];
    if (unread.isEmpty) return;
    unawaited(_markAllRead(unread).catchError((Object _) {}));
  }

  @override
  void dispose() {
    _disposed = true;
    _watch.cancel();
    super.dispose();
  }
}
