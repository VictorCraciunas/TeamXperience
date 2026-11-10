import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/widgets/greeting_stats.dart';
import 'package:teamxperience/features/home/widgets/home_layout.dart';
import 'package:teamxperience/features/home/widgets/new_player_greeting.dart';
import 'package:teamxperience/features/home/widgets/nothing_open_banner.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../../ui/pump_ui.dart';

double _top(WidgetTester tester, String text) => tester.getTopLeft(find.text(text)).dy;

void main() {
  testWidgets('order: greeting, memory first, card, events, memory, past, season, news', (tester) async {
    await pumpUi(
      tester,
      SingleChildScrollView(
        child: HomeLayout(
          hero: const NoHero(),
          greeting: const Text('salut'),
          memoryFirst: const Text('amintire nouă'),
          mainCard: const Text('card'),
          newEvents: const Text('evenimente'),
          memory: const Text('amintire'),
          pastGames: const Text('trecute'),
          season: const Text('sezon'),
          news: const Text('știri'),
        ),
      ),
    );
    final order = ['salut', 'amintire nouă', 'card', 'evenimente', 'amintire', 'trecute', 'sezon', 'știri'];
    for (var i = 1; i < order.length; i++) {
      expect(_top(tester, order[i]), greaterThan(_top(tester, order[i - 1])), reason: order[i]);
    }
  });

  testWidgets('a part that is null leaves no gap', (tester) async {
    await pumpUi(
      tester,
      SingleChildScrollView(
        child: HomeLayout(hero: const NoHero(), greeting: const Text('salut'), news: const Text('știri')),
      ),
    );
    final together = _top(tester, 'știri') - _top(tester, 'salut');
    await pumpUi(
      tester,
      SingleChildScrollView(
        child: HomeLayout(hero: const NoHero(), greeting: const Text('salut'), season: const Text('sezon'), news: const Text('știri')),
      ),
    );
    expect(_top(tester, 'știri') - _top(tester, 'salut'), greaterThan(together));
  });

  testWidgets('during a game only the live parts show', (tester) async {
    await pumpUi(
      tester,
      SingleChildScrollView(
        child: HomeLayout(
          hero: LiveHero(sampleEvent(), sampleTeam()),
          greeting: const Text('salut'),
          mainCard: const Text('card'),
          live: const Text('clasament'),
          newEvents: const Text('evenimente'),
          memory: const Text('amintire'),
          news: const Text('știri'),
        ),
      ),
    );
    expect(find.text('card'), findsOneWidget);
    expect(find.text('clasament'), findsOneWidget);
    for (final gone in ['salut', 'evenimente', 'amintire', 'știri']) {
      expect(find.text(gone), findsNothing, reason: gone);
    }
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('new player, nothing open, no news fits 320 px at 1.3x (${theme.brightness.name})', (tester) async {
      await pumpUi(
        tester,
        SingleChildScrollView(
          child: HomeLayout(
            hero: const NoHero(),
            greeting: NewPlayerGreeting(firstName: 'Victor-Alexandru', onHow: () {}),
            mainCard: const NothingOpenBanner(),
          ),
        ),
        width: 320,
        textScale: 1.3,
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a regular player keeps the stats', (tester) async {
    await pumpUi(
      tester,
      SingleChildScrollView(
        child: HomeLayout(
          hero: const NoHero(),
          greeting: const GreetingStats(firstName: 'Victor', games: 3, distanceMeters: 12400, xp: 800),
          mainCard: const NothingOpenBanner(),
        ),
      ),
      width: 320,
      textScale: 1.3,
    );
    expect(find.text('jocuri'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
