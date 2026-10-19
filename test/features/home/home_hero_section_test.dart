import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/features/home/widgets/home_hero_section.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/event/countdown_tiles.dart';
import 'package:teamxperience/ui/components/event/event_hero_card.dart';

import '../../ui/pump_ui.dart';

final _now = DateTime(2026, 10, 20, 12);

Event _event({
  Duration startedAgo = const Duration(minutes: 45),
  int nrMissions = 5,
  String? image,
  String? route,
}) {
  return Event(
    eventId: 'e1',
    name: 'Treasure Hunt Sibiu',
    location: 'Piața Mare',
    dateEvent: _now.subtract(startedAgo),
    nrMissions: nrMissions,
    landingImageUrl: image,
    lungimeTraseu: route,
  );
}

Team _team({int progress = 1}) => Team(
      name: 'Vulturii',
      teamMembers: 'Ana, Dan',
      captainName: 'Ana',
      phoneNumber: '0712345678',
      captainEmail: 'ana@example.com',
      hasStarted: true,
      missionProgress: progress,
    );

class _Calls {
  final log = <String>[];

  HomeHeroActions get actions => HomeHeroActions(
        onContinue: (e, t) => log.add('continue:${e.eventId}:${t.name}'),
        onChat: (e, t) => log.add('chat:${e.eventId}'),
        onEnterCode: (e) => log.add('code:${e.eventId}'),
        onDetails: (e) => log.add('details:${e.eventId}'),
        onShare: (e) => log.add('share:${e.eventId}'),
        onRegister: (e) => log.add('register:${e.eventId}'),
      );
}

Future<_Calls> _pump(
  WidgetTester tester,
  HomeHero hero, {
  int? recommendedTeamCount,
  double textScale = 1,
}) async {
  final calls = _Calls();
  await pumpUi(
    tester,
    HomeHeroSection(
      hero: hero,
      now: _now,
      actions: calls.actions,
      recommendedTeamCount: recommendedTeamCount,
    ),
    textScale: textScale,
  );
  return calls;
}

int _segments(String kind) => find
    .byWidgetPredicate((w) {
      final key = w.key;
      return key is ValueKey<String> && key.value.startsWith('hero-segment-$kind');
    })
    .evaluate()
    .length;

void main() {
  group('live', () {
    testWidgets('shows the live card with time left, mission and progress', (tester) async {
      await _pump(tester, LiveHero(_event(), _team()));
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('2:15:00 rămase'), findsOneWidget);
      expect(find.text('Vulturii · Misiunea 2 din 5'), findsOneWidget);
      expect(find.text('Continuă jocul'), findsOneWidget);
      expect(_segments('done'), 1);
    });

    testWidgets('continue and chat call back with the event and the team', (tester) async {
      final calls = await _pump(tester, LiveHero(_event(), _team()));
      await tester.tap(find.text('Continuă jocul'));
      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      expect(calls.log, ['continue:e1:Vulturii', 'chat:e1']);
    });

    testWidgets('an event with no missions shows no progress', (tester) async {
      await _pump(tester, LiveHero(_event(nrMissions: 0), _team(progress: 0)));
      expect(_segments(''), 0);
    });

    testWidgets('the mission number never goes past the last mission', (tester) async {
      await _pump(tester, LiveHero(_event(nrMissions: 3), _team(progress: 3)));
      expect(find.text('Vulturii · Misiunea 3 din 3'), findsOneWidget);
    });
  });

  group('starting soon', () {
    testWidgets('shows minutes left and the enter code action', (tester) async {
      final calls = await _pump(tester, StartingSoonHero(_event(), 47));
      expect(find.text('A început'), findsOneWidget);
      expect(find.text('Mai ai 47 min să intri'), findsOneWidget);
      await tester.tap(find.text('Introdu codul de start'));
      expect(calls.log, ['code:e1']);
    });
  });

  group('upcoming', () {
    testWidgets('shows the countdown, details and share actions', (tester) async {
      final calls = await _pump(
        tester,
        UpcomingHero(_event(), const Duration(days: 3, hours: 14, minutes: 22)),
      );
      expect(find.text('Următorul eveniment'), findsOneWidget);
      expect(find.byType(CountdownTiles), findsOneWidget);
      await tester.tap(find.text('Detalii înscriere'));
      await tester.tap(find.byIcon(Icons.share_outlined));
      expect(calls.log, ['details:e1', 'share:e1']);
    });
  });

  group('recommended', () {
    testWidgets('shows the facts line and the register action', (tester) async {
      final calls = await _pump(
        tester,
        RecommendedHero(_event(route: '4 km')),
        recommendedTeamCount: 12,
      );
      expect(find.text('Recomandat pentru tine'), findsOneWidget);
      expect(find.textContaining('4 km'), findsOneWidget);
      expect(find.textContaining('12 echipe'), findsOneWidget);
      await tester.tap(find.text('Înscrie-ți echipa'));
      expect(calls.log, ['register:e1']);
    });

    testWidgets('leaves out the team count and route when unknown', (tester) async {
      await _pump(tester, RecommendedHero(_event()));
      expect(find.textContaining('echipe'), findsNothing);
      expect(find.textContaining('km'), findsNothing);
    });
  });

  testWidgets('no hero renders nothing', (tester) async {
    await _pump(tester, const NoHero());
    expect(find.byType(EventHeroCard), findsNothing);
  });

  testWidgets('an empty cover image URL renders without errors', (tester) async {
    await _pump(tester, LiveHero(_event(image: ''), _team()), textScale: 1.5);
    expect(tester.takeException(), isNull);
  });
}
