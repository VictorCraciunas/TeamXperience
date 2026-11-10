import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/notifications/widgets/notifications_view.dart';
import 'package:teamxperience/model/app_notification.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../../ui/pump_ui.dart';

final _now = DateTime(2026, 11, 9, 14);

AppNotification _n(String title, {NotificationKind kind = NotificationKind.chat, DateTime? at, bool read = false, String body = 'Text'}) =>
    AppNotification(id: title, kind: kind, title: title, body: body, createdAt: at, read: read);

Future<void> _pump(
  WidgetTester tester,
  List<AppNotification> items, {
  bool failed = false,
  ValueChanged<AppNotification>? onOpen,
  double width = 360,
  double textScale = 1,
  ThemeData? theme,
}) =>
    pumpUi(
      tester,
      NotificationsView(items: items, failed: failed, now: _now, onOpen: onOpen ?? (_) {}),
      width: width,
      textScale: textScale,
      theme: theme,
    );

void main() {
  testWidgets('rows under Azi and Mai devreme, with their texts and times', (tester) async {
    await _pump(tester, [
      _n('Startul s-a mutat', at: _now.subtract(const Duration(minutes: 10)), body: 'La Turnul Sfatului.'),
      _n('Rezultatele sunt gata', kind: NotificationKind.results, at: DateTime(2026, 11, 7, 18), read: true),
    ]);
    for (final text in ['Azi', 'Mai devreme', 'Startul s-a mutat', 'La Turnul Sfatului.', 'acum 10 min', 'Rezultatele sunt gata', '7 nov']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(tester.getTopLeft(find.text('Azi')).dy, lessThan(tester.getTopLeft(find.text('Mai devreme')).dy));
  });

  testWidgets('a group with nothing leaves its title out', (tester) async {
    await _pump(tester, [_n('Vechi', at: DateTime(2026, 11, 7))]);
    expect(find.text('Azi'), findsNothing);
    expect(find.text('Mai devreme'), findsOneWidget);
  });

  testWidgets('unread rows have the dot, read ones not', (tester) async {
    await _pump(tester, [_n('Nou', at: _now), _n('Citit', at: _now, read: true)]);
    expect(find.byKey(const ValueKey('notification-unread')), findsOneWidget);
  });

  testWidgets('tapping a row opens it', (tester) async {
    AppNotification? opened;
    await _pump(tester, [_n('Nou', at: _now)], onOpen: (n) => opened = n);
    await tester.tap(find.text('Nou'));
    expect(opened?.id, 'Nou');
  });

  testWidgets('empty: the two lines', (tester) async {
    await _pump(tester, const []);
    expect(find.text('Nicio notificare încă'), findsOneWidget);
    expect(find.text('Aici apar mesajele organizatorului, noutățile echipei tale și rezultatele jocurilor.'), findsOneWidget);
  });

  testWidgets('failed: its line', (tester) async {
    await _pump(tester, const [], failed: true);
    expect(find.text('Nu am putut încărca notificările.'), findsOneWidget);
  });

  testWidgets('each kind has its icon, an unknown one the plain bell', (tester) async {
    await _pump(tester, [
      _n('a', kind: NotificationKind.announcement, at: _now),
      _n('b', kind: NotificationKind.chat, at: _now),
      _n('c', kind: NotificationKind.team, at: _now),
      _n('d', kind: NotificationKind.results, at: _now),
      _n('e', kind: NotificationKind.other, at: _now),
    ]);
    for (final icon in [TablerIcons.speakerphone, TablerIcons.message_circle, TablerIcons.users_group, TablerIcons.trophy, TablerIcons.bell]) {
      expect(find.byIcon(icon), findsOneWidget);
    }
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('fits 320 px at 1.3x text with long texts (${theme.brightness.name})', (tester) async {
      final long = 'Un mesaj foarte lung de la organizator despre locul de întâlnire ' * 3;
      await _pump(tester, [_n(long, at: _now, body: long), _n('Scurt', at: DateTime(2026, 11, 1), read: true)], width: 320, textScale: 1.3, theme: theme);
      expect(tester.takeException(), isNull);
      await _pump(tester, const [], width: 320, textScale: 1.3, theme: theme);
      expect(tester.takeException(), isNull);
    });
  }
}
