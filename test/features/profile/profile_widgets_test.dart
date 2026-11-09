import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/features/profile/logic/badge_catalog.dart';
import 'package:teamxperience/features/profile/widgets/badge_sheet.dart';
import 'package:teamxperience/features/profile/widgets/badge_tile.dart';
import 'package:teamxperience/features/profile/widgets/badges_section.dart';
import 'package:teamxperience/features/profile/widgets/memories_section.dart';
import 'package:teamxperience/features/profile/widgets/profile_account_card.dart';
import 'package:teamxperience/features/profile/widgets/profile_settings_card.dart';
import 'package:teamxperience/features/profile/widgets/profile_stats_row.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/user_stats.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../../ui/pump_ui.dart';

const _c = AppColors.light;

ProfileBadge _badge(String id) => badgeCatalog.firstWhere((b) => b.id == id);

const _memory = Memory(
  eventId: 'e1',
  eventName: 'Moștenirea Cartografului',
  place: 2,
  totalMinutes: 108,
  photoUrls: ['a', 'b', 'c', 'd', 'e', 'f'],
);

void main() {
  group('ProfileAccountCard', () {
    testWidgets('initials, name, level and the next level', (tester) async {
      await pumpUi(tester, ProfileAccountCard(name: 'Victor Crăciunaș', email: 'v@x.ro', level: levelInfo(640)));
      expect(find.text('VC'), findsOneWidget);
      expect(find.text('Victor Crăciunaș'), findsOneWidget);
      expect(find.text('Explorator · 640 / 1000 XP'), findsOneWidget);
      expect(find.text('Următorul: Cartograf'), findsOneWidget);
      expect(find.text('v@x.ro'), findsNothing);
    });

    testWidgets('at the top: no next level, a full bar', (tester) async {
      await pumpUi(tester, ProfileAccountCard(name: 'Ana', email: 'a@x.ro', level: levelInfo(3100)));
      expect(find.text('Legendă · 3100 XP'), findsOneWidget);
      expect(find.text('Nivel maxim'), findsOneWidget);
      expect(tester.widget<FractionallySizedBox>(find.byKey(const ValueKey('xp-fill'))).widthFactor, 1);
    });

    testWidgets('an admin: the email, no level', (tester) async {
      await pumpUi(tester, const ProfileAccountCard(name: 'Victor Crăciunaș', email: 'v@x.ro'));
      expect(find.text('v@x.ro'), findsOneWidget);
      expect(find.byKey(const ValueKey('xp-bar')), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
    });

    testWidgets('one word, no name, a very long name', (tester) async {
      await pumpUi(tester, const ProfileAccountCard(name: 'Ana', email: ''));
      expect(find.text('A'), findsOneWidget);
      await pumpUi(tester, const ProfileAccountCard(name: '', email: ''));
      expect(tester.takeException(), isNull);
      await pumpUi(
        tester,
        ProfileAccountCard(name: 'Alexandru-Constantin Popescu-Ionescu de la Sibiu', email: '', level: levelInfo(0)),
        width: 320,
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('ProfileStatsRow', () {
    testWidgets('four stats with labels that agree', (tester) async {
      await pumpUi(
        tester,
        const ProfileStatsRow(stats: UserStats(games: 3, distanceMeters: 12400, missions: 17, podiums: 1)),
      );
      for (final text in ['3', 'jocuri', '12,4', 'km', '17', 'misiuni', '1', 'podium']) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('a new player: zeros', (tester) async {
      await pumpUi(tester, const ProfileStatsRow(stats: UserStats()));
      expect(find.text('0'), findsNWidgets(3));
      expect(find.text('0,0'), findsOneWidget);
      expect(find.text('podiumuri'), findsOneWidget);
    });
  });

  group('BadgeTile', () {
    testWidgets('earned: its title, and a tap', (tester) async {
      var taps = 0;
      await pumpUi(tester, BadgeTile(badge: _badge('km10'), earned: true, onTap: () => taps++));
      expect(find.text('Primii 10 km'), findsOneWidget);
      await tester.tap(find.text('Primii 10 km'));
      expect(taps, 1);
    });

    testWidgets('locked: a lock at 45 %', (tester) async {
      await pumpUi(tester, BadgeTile(badge: _badge('winner'), earned: false));
      expect(find.byIcon(TablerIcons.lock), findsOneWidget);
      expect(find.byIcon(TablerIcons.trophy), findsNothing);
      expect(tester.widget<Opacity>(find.ancestor(of: find.text('Câștigă un joc'), matching: find.byType(Opacity))).opacity, .45);
    });
  });

  group('BadgesSection', () {
    testWidgets('the count, four tiles, and both ways to open them all', (tester) async {
      var opened = 0;
      await pumpUi(tester, BadgesSection(earned: const ['km10', 'noHints', 'night', 'firstGame'], onOpenAll: () => opened++));
      expect(find.text('Insigne'), findsOneWidget);
      expect(find.text('4 din 12'), findsOneWidget);
      expect(find.byType(BadgeTile), findsNWidgets(4));
      await tester.tap(find.text('4 din 12'));
      await tester.tap(find.text('Primii 10 km'));
      expect(opened, 2);
    });

    testWidgets('nothing earned: 0 din 12 and four locks', (tester) async {
      await pumpUi(tester, BadgesSection(earned: const [], onOpenAll: () {}));
      expect(find.text('0 din 12'), findsOneWidget);
      expect(find.byIcon(TablerIcons.lock), findsNWidgets(4));
    });
  });

  testWidgets('the sheet lists all twelve; a locked one says how to earn it', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpUi(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showBadgeSheet(context, earned: const ['km10']),
          child: const Text('deschide'),
        ),
      ),
    );
    await tester.tap(find.text('deschide'));
    await tester.pumpAndSettle();
    expect(find.text('1 din 12'), findsOneWidget);
    for (final badge in badgeCatalog) {
      expect(find.text(badge.title), findsOneWidget, reason: badge.id);
    }
    expect(find.text(_badge('winner').rule), findsOneWidget);
    expect(find.text(_badge('km10').rule), findsNothing, reason: 'already earned');
  });

  group('MemoriesSection', () {
    testWidgets('Toate shows with a handler and opens the list', (tester) async {
      var all = 0;
      await pumpUi(tester, MemoriesSection(memories: const [_memory], onOpen: (_) {}, onAll: () => all++));
      await tester.tap(find.text('Toate'));
      expect(all, 1);
    });

    testWidgets('the mockup\'s card; a tap gives the memory', (tester) async {
      Memory? tapped;
      await pumpUi(tester, MemoriesSection(memories: const [_memory], onOpen: (m) => tapped = m));
      expect(find.text('Amintiri'), findsOneWidget);
      expect(find.text('Moștenirea Cartografului'), findsOneWidget);
      expect(find.text('Locul 2 · 1:48 · 6 poze'), findsOneWidget);
      await tester.tap(find.text('Moștenirea Cartografului'));
      expect(tapped, _memory);
    });

    testWidgets('none yet: says where they will appear', (tester) async {
      await pumpUi(tester, MemoriesSection(memories: const [], onOpen: (_) {}));
      expect(find.text('Aici apar jocurile tale terminate.'), findsOneWidget);
    });

    testWidgets('a failed read says so, not "none yet"', (tester) async {
      await pumpUi(tester, MemoriesSection(memories: const [], failed: true, onOpen: (_) {}));
      expect(find.text('Nu am putut încărca amintirile.'), findsOneWidget);
      expect(find.text('Aici apar jocurile tale terminate.'), findsNothing);
    });

    testWidgets('at most three', (tester) async {
      await pumpUi(tester, MemoriesSection(memories: const [_memory, _memory, _memory, _memory], onOpen: (_) {}));
      expect(find.byKey(const ValueKey('memory-thumb')), findsNWidgets(3));
    });
  });

  group('ProfileSettingsCard', () {
    testWidgets('the three rows and what they say', (tester) async {
      final calls = <String>[];
      await pumpUi(
        tester,
        ProfileSettingsCard(
          themeLabel: 'Luminos',
          notificationsLabel: 'Activate',
          onTheme: () => calls.add('theme'),
          onNotifications: () => calls.add('notifications'),
          onLogout: () => calls.add('logout'),
        ),
      );
      expect(find.text('Luminos'), findsOneWidget);
      expect(find.text('Activate'), findsOneWidget);
      expect(tester.widget<Text>(find.text('Deconectare')).style?.color, _c.danger);
      await tester.tap(find.text('Temă'));
      await tester.tap(find.text('Notificări'));
      await tester.tap(find.text('Deconectare'));
      expect(calls, ['theme', 'notifications', 'logout']);
    });
  });
}
