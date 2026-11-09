import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/notifications/controller/notifications_controller.dart';
import 'package:teamxperience/model/app_notification.dart';

AppNotification _n(String id, {bool read = false}) =>
    AppNotification(id: id, kind: NotificationKind.chat, title: 'T', body: 'B', read: read);

class _Harness {
  final stream = StreamController<List<AppNotification>>();
  final marked = <String>[];
  final allMarked = <List<String>>[];
  bool fail = false;

  _Harness() {
    // Listening from the start, as the screen does.
    controller;
  }

  late final NotificationsController controller = NotificationsController(
    stream: stream.stream,
    markRead: (id) async {
      if (fail) throw Exception('offline');
      marked.add(id);
    },
    markAllRead: (ids) async {
      if (fail) throw Exception('offline');
      allMarked.add(ids.toList());
    },
  );
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('follows the stream; loading ends', () async {
    final h = _Harness();
    expect(h.controller.loading, isTrue);
    h.stream.add([_n('a'), _n('b', read: true)]);
    await _settle();
    expect(h.controller.loading, isFalse);
    expect(h.controller.items.map((n) => n.id), ['a', 'b']);
    expect(h.controller.hasUnread, isTrue);
  });

  test('a failure says so', () async {
    final h = _Harness();
    h.stream.addError(Exception('denied'));
    await _settle();
    expect((h.controller.failed, h.controller.loading), (true, false));
  });

  test('opening marks an unread row read, and a read one not again', () async {
    final h = _Harness();
    await h.controller.open(_n('a'));
    await h.controller.open(_n('b', read: true));
    expect(h.marked, ['a']);
  });

  test('a failing mark does not throw', () async {
    final h = _Harness()..fail = true;
    await h.controller.open(_n('a'));
    await h.controller.markAll();
  });

  test('mark all sends only the unread ids', () async {
    final h = _Harness();
    h.stream.add([_n('a'), _n('b', read: true), _n('c')]);
    await _settle();
    await h.controller.markAll();
    expect(h.allMarked, [
      ['a', 'c'],
    ]);
  });

  test('mark all with nothing unread writes nothing', () async {
    final h = _Harness();
    h.stream.add([_n('b', read: true)]);
    await _settle();
    expect(h.controller.hasUnread, isFalse);
    await h.controller.markAll();
    expect(h.allMarked, isEmpty);
  });

  test('dispose stops following', () async {
    final h = _Harness();
    h.controller.dispose();
    h.stream.add([_n('a')]);
    await _settle();
  });
}
