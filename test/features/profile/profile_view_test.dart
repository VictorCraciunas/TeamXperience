import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/profile/widgets/profile_view.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/user_stats.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<List<String>> _pump(
  WidgetTester tester, {
  bool player = true,
  int xp = 640,
  UserStats stats = const UserStats(games: 3, distanceMeters: 12400, missions: 17, podiums: 1),
  List<String> badges = const ['km10', 'noHints', 'night', 'firstGame'],
  List<Memory> memories = const [
    Memory(eventId: 'e1', eventName: 'Moștenirea Cartografului', place: 2, totalMinutes: 108, photoUrls: ['a']),
  ],
  String name = 'Victor Crăciunaș',
  ThemeData? theme,
  double width = 316,
  double textScale = 1,
}) async {
  final calls = <String>[];
  tester.view.physicalSize = Size(width * 2, 1000 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        child: ProfileView(
          player: player,
          name: name,
          email: 'victor@example.com',
          xp: xp,
          stats: stats,
          badges: badges,
          memories: memories,
          themeLabel: 'Luminos',
          notificationsLabel: 'Oprite',
          onTheme: () => calls.add('theme'),
          onNotifications: () => calls.add('notifications'),
          onLogout: () => calls.add('logout'),
          onOpenBadges: () => calls.add('badges'),
          onOpenMemory: (m) => calls.add('memory ${m.eventId}'),
        ),
      ),
    ),
  ));
  return calls;
}

void main() {
  testWidgets('a player sees everything from the mockup', (tester) async {
    await _pump(tester);
    for (final text in [
      'Victor Crăciunaș',
      'Explorator · 640 / 1000 XP',
      'Următorul: Cartograf',
      'jocuri',
      'Insigne',
      '4 din 12',
      'Amintiri',
      'Moștenirea Cartografului',
      'Temă',
      'Notificări',
      'Deconectare',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('a brand-new player: starter values', (tester) async {
    await _pump(tester, xp: 0, stats: const UserStats(), badges: const [], memories: const []);
    expect(find.text('Începător · 0 / 500 XP'), findsOneWidget);
    expect(find.text('Următorul: Explorator'), findsOneWidget);
    expect(find.text('0 din 12'), findsOneWidget);
    expect(find.text('Aici apar jocurile tale terminate.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an admin: the account and the settings, nothing about playing', (tester) async {
    await _pump(tester, player: false, xp: 0, stats: const UserStats(), badges: const [], memories: const []);
    expect(find.text('Victor Crăciunaș'), findsOneWidget);
    expect(find.text('victor@example.com'), findsOneWidget);
    expect(find.text('Deconectare'), findsOneWidget);
    for (final text in ['Insigne', 'Amintiri', 'jocuri', 'misiuni']) {
      expect(find.text(text), findsNothing, reason: text);
    }
    expect(find.textContaining('XP'), findsNothing);
  });

  testWidgets('every action calls back', (tester) async {
    final calls = await _pump(tester);
    await tester.tap(find.text('4 din 12'));
    await tester.tap(find.text('Moștenirea Cartografului'));
    await tester.tap(find.text('Temă'));
    await tester.tap(find.text('Notificări'));
    await tester.tap(find.text('Deconectare'));
    expect(calls, ['badges', 'memory e1', 'theme', 'notifications', 'logout']);
  });

  testWidgets('teams are a tab now, so Profil does not list them', (tester) async {
    await _pump(tester);
    expect(find.text('Echipele mele'), findsNothing);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('fits 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
      await _pump(
        tester,
        theme: theme,
        width: 320,
        textScale: 1.3,
        name: 'Alexandru-Constantin Popescu-Ionescu de la Sibiu',
        stats: const UserStats(games: 123, distanceMeters: 1234000, missions: 1234, podiums: 45),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
