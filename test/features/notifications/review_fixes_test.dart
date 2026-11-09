import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/home/controller/home_extras_controller.dart';
import 'package:teamxperience/features/notifications/controller/notifications_controller.dart';
import 'package:teamxperience/features/notifications/logic/open_notifications.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/model/app_notification.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';

AppNotification _n(String id, {bool read = false}) =>
    AppNotification(id: id, kind: NotificationKind.team, title: 'T', body: 'B', read: read);

void main() {
  testWidgets('a notification that leads to Echipe opens that tab after the page closes', (tester) async {
    final shell = ShellController(5);
    late NavigatorState navigator;
    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.notifications: (context) => TextButton(
              onPressed: () => Navigator.pop(context, PlayerTab.teams),
              child: const Text('Echipa ta crește'),
            ),
      },
      home: Builder(builder: (context) {
        navigator = Navigator.of(context);
        return const SizedBox();
      }),
    ));
    final opening = openNotificationsPage(navigator, shell);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Echipa ta crește'));
    await tester.pumpAndSettle();
    await opening;
    expect(shell.index, PlayerTab.teams);
  });

  testWidgets('closing the page any other way leaves the tab alone', (tester) async {
    final shell = ShellController(5);
    late NavigatorState navigator;
    await tester.pumpWidget(MaterialApp(
      routes: {Routes.notifications: (context) => const Text('pagina')},
      home: Builder(builder: (context) {
        navigator = Navigator.of(context);
        return const SizedBox();
      }),
    ));
    final opening = openNotificationsPage(navigator, shell);
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();
    await opening;
    expect(shell.index, PlayerTab.home);
  });

  test('a tap does not wait for the server to mark the row read', () async {
    final never = Completer<void>();
    final controller = NotificationsController(
      stream: const Stream.empty(),
      markRead: (_) => never.future,
      markAllRead: (_) async {},
    );
    await controller.open(_n('a')).timeout(const Duration(seconds: 1));
  });

  test('the bell follows the same newest notifications as the page', () async {
    final list = StreamController<List<AppNotification>>.broadcast();
    final extras = HomeExtrasController(
      memories: (_) => const Stream.empty(),
      crews: (_) => const Stream.empty(),
      standings: const Stream.empty(),
      seasonName: 'Toamna 2026',
      findTeam: (_, __) async => null,
      notifications: (_) => list.stream,
    );
    extras.watch('u1');
    await Future<void>.delayed(Duration.zero);
    list.add([_n('a', read: true), _n('b')]);
    await Future<void>.delayed(Duration.zero);
    expect(extras.hasUnread, isTrue);
    list.add([_n('a', read: true), _n('b', read: true)]);
    await Future<void>.delayed(Duration.zero);
    expect(extras.hasUnread, isFalse);
  });
}
