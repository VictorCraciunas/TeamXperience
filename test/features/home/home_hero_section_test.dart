import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/features/home/widgets/home_hero_section.dart';
import 'package:teamxperience/features/home/widgets/navy_game_card.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../../ui/pump_ui.dart';

/// The sample event starts Sâm 14 nov at 10:00; this is 3 d 14 h 22 min before.
final _before = DateTime(2026, 11, 10, 19, 38);

Team _team({int progress = 0, int members = 4, bool started = false}) => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Victor',
      phoneNumber: '',
      captainEmail: '',
      numberOfMembers: 4,
      missionProgress: progress,
      hasStarted: started,
      members: [
        for (var i = 0; i < members; i++) TeamMember(uid: 'u$i', displayName: 'M $i', initials: 'M$i'),
      ],
    );

class _Calls {
  final log = <String>[];

  HomeHeroActions get actions => HomeHeroActions(
        onContinue: (e, t) => log.add('continue:${t.name}'),
        onChat: (e, t) => log.add('chat'),
        onEnterCode: (e) => log.add('code'),
        onDetails: (e) => log.add('details'),
        onShare: (e) => log.add('share'),
        onRegister: (e) => log.add('register'),
      );
}

Future<_Calls> _pump(
  WidgetTester tester,
  HomeHero hero, {
  required DateTime now,
  Team? upcomingTeam,
  double width = 360,
  double textScale = 1,
  ThemeData? theme,
}) async {
  final calls = _Calls();
  await pumpUi(
    tester,
    HomeHeroSection(hero: hero, now: now, actions: calls.actions, upcomingTeam: upcomingTeam),
    width: width,
    textScale: textScale,
    theme: theme,
  );
  return calls;
}

void main() {
  final event = sampleEvent();

  group('next game', () {
    final hero = UpcomingHero(event, const Duration(days: 3, hours: 14, minutes: 22));

    testWidgets('the badge, the name, day, time and start point, and the countdown', (tester) async {
      await _pump(tester, hero, now: _before, upcomingTeam: _team(members: 4));
      expect(find.text('Următorul tău joc'), findsOneWidget);
      expect(find.text('Moștenirea Cartografului'), findsOneWidget);
      expect(find.text('Sâm 14 nov · 10:00 · Piața Mare'), findsOneWidget);
      for (final t in ['3', '14', '22']) {
        expect(find.text(t), findsOneWidget);
      }
      expect(tester.widget<NavyGameCard>(find.byType(NavyGameCard)).fill, NavyFill.navy);
    });

    testWidgets("with the team: its preparation, two of three done for a full team days before", (tester) async {
      await _pump(tester, hero, now: _before, upcomingTeam: _team(members: 4));
      expect(find.text('Pregătirea echipei Vulpile'), findsOneWidget);
      expect(find.text('Echipă completă'), findsOneWidget);
      expect(find.byIcon(TablerIcons.check), findsNWidgets(2));
    });

    testWidgets('without the team (still loading): no preparation band', (tester) async {
      await _pump(tester, hero, now: _before);
      expect(find.textContaining('Pregătirea'), findsNothing);
    });

    testWidgets('a tap opens the registration details', (tester) async {
      final calls = await _pump(tester, hero, now: _before, upcomingTeam: _team());
      await tester.tap(find.text('Moștenirea Cartografului'));
      expect(calls.log, ['details']);
    });
  });

  group('live', () {
    final live = DateTime(2026, 11, 14, 11, 42, 18); // 1:17:42 before 10:00 + 3 h

    testWidgets('LIVE, the time left, the team and mission, the progress line', (tester) async {
      await _pump(tester, LiveHero(event, _team(progress: 3, started: true)), now: live);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('1:17:42'), findsOneWidget);
      expect(find.text('rămase'), findsOneWidget);
      expect(find.text('Echipa Vulpile · misiunea 4 din 6'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.byIcon(TablerIcons.flag), findsOneWidget);
      expect(tester.widget<NavyGameCard>(find.byType(NavyGameCard)).fill, NavyFill.live);
    });

    testWidgets('Continuă jocul and the chat button call back', (tester) async {
      final calls = await _pump(tester, LiveHero(event, _team(progress: 3, started: true)), now: live);
      await tester.tap(find.text('Continuă jocul'));
      await tester.tap(find.byIcon(TablerIcons.message_circle));
      expect(calls.log, ['continue:Vulpile', 'chat']);
    });

    testWidgets('a fresher streamed team wins over the stale one: its mission, and Continue opens it', (tester) async {
      Team? opened;
      final stale = _team(progress: 3, started: true);
      final fresh = _team(progress: 4, started: true);
      await pumpUi(
        tester,
        HomeHeroSection(
          hero: LiveHero(event, stale),
          now: live,
          actions: HomeHeroActions(
            onContinue: (_, t) => opened = t,
            onChat: (_, _) {},
            onEnterCode: (_) {},
            onDetails: (_) {},
            onShare: (_) {},
            onRegister: (_) {},
          ),
          liveTeam: (name) => name == 'Vulpile' ? fresh : null,
        ),
      );
      expect(find.text('Echipa Vulpile · misiunea 5 din 6'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      await tester.tap(find.text('Continuă jocul'));
      expect(opened?.missionProgress, 4);
    });

    testWidgets('an event without missions: just the team and the flag', (tester) async {
      final none = sampleEvent()..nrMissions = 0;
      await _pump(tester, LiveHero(none, _team(started: true)), now: live);
      expect(find.text('Echipa Vulpile'), findsOneWidget);
      expect(find.byIcon(TablerIcons.flag), findsOneWidget);
      expect(find.byKey(const ValueKey('mission-current')), findsNothing);
    });

    testWidgets('past the end the clock stops at 0:00:00', (tester) async {
      await _pump(tester, LiveHero(event, _team(progress: 3, started: true)), now: DateTime(2026, 11, 14, 13, 5));
      expect(find.text('0:00:00'), findsOneWidget);
    });
  });

  testWidgets('code window open: A început, the minutes left and the code button', (tester) async {
    final calls = await _pump(tester, StartingSoonHero(event, 42), now: DateTime(2026, 11, 14, 10, 18));
    expect(find.text('A început'), findsOneWidget);
    expect(find.text('Mai ai 42 min să intri'), findsOneWidget);
    await tester.tap(find.text('Introdu codul de start'));
    expect(calls.log, ['code']);
  });

  testWidgets('recommended: the badge, the day line with the route facts, and the register button', (tester) async {
    final calls = await _pump(tester, RecommendedHero(event), now: _before);
    expect(find.text('Recomandat pentru tine'), findsOneWidget);
    expect(find.textContaining('Sâm 14 nov · 10:00 · Piața Mare'), findsOneWidget);
    await tester.tap(find.text('Înscrie-ți echipa'));
    expect(calls.log, ['register']);
  });

  testWidgets('no hero: nothing', (tester) async {
    await _pump(tester, const NoHero(), now: _before);
    expect(find.byType(NavyGameCard), findsNothing);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('every card fits 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
      final heroes = <(HomeHero, DateTime)>[
        (UpcomingHero(event, const Duration(days: 3, hours: 14, minutes: 22)), _before),
        (LiveHero(event, _team(progress: 3, started: true)), DateTime(2026, 11, 14, 11, 42, 18)),
        (StartingSoonHero(event, 42), DateTime(2026, 11, 14, 10, 18)),
        (RecommendedHero(event), _before),
      ];
      for (final (hero, now) in heroes) {
        await _pump(tester, hero, now: now, upcomingTeam: _team(), width: 320, textScale: 1.3, theme: theme);
        expect(tester.takeException(), isNull, reason: hero.signature);
      }
    });
  }

  test('the sample event has six missions and its start point', () {
    expect(event.nrMissions, 6);
    expect(event.punctDeStart, 'Piața Mare');
    expect(event.dateEvent, DateTime(2026, 11, 14, 10));
    expect(Event.maxDuration, const Duration(hours: 3));
  });
}
