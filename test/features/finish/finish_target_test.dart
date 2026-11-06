import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/finish/controller/finish_controller.dart';
import 'package:teamxperience/features/finish/logic/finish_target.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';

final _event = Event(
  eventId: 'e1',
  name: 'Moștenirea Cartografului',
  dateEvent: DateTime(2026, 11, 14, 10),
  missions: [for (var i = 0; i < 6; i++) Mission(id: '$i')],
);

Team _team(String name, {int progress = 6, bool finished = false}) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      missionProgress: progress,
      hasStarted: true,
      hasFinished: finished,
    );

void main() {
  group('showFinish', () {
    test('after the last mission, when the event ended, or for a finished team', () {
      expect(showFinish(_event, _team('V'), eventEnded: false), isTrue);
      expect(showFinish(_event, _team('V', progress: 3), eventEnded: true), isTrue);
      expect(showFinish(_event, _team('V', progress: 3, finished: true), eventEnded: false), isTrue);
    });

    test('not in the middle of the game', () {
      expect(showFinish(_event, _team('V', progress: 3), eventEnded: false), isFalse);
    });
  });

  group('openFinishNow', () {
    test('while a puzzle is open on top of the route, only the end of the event moves it', () {
      expect(openFinishNow(_event, _team('V'), eventEnded: false, routeOnTop: false), isFalse,
          reason: 'the puzzle that solved the last mission is still writing; it comes back with the team');
      expect(openFinishNow(_event, _team('V', progress: 3), eventEnded: true, routeOnTop: false), isTrue);
    });

    test('with the route on top, any reason to finish opens it', () {
      expect(openFinishNow(_event, _team('V'), eventEnded: false, routeOnTop: true), isTrue);
      expect(openFinishNow(_event, _team('V', progress: 3), eventEnded: false, routeOnTop: true), isFalse);
    });
  });

  group('replaceWithFinish', () {
    Future<NavigatorState> app(WidgetTester tester) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: key,
        home: const Text('shell'),
        routes: {
          '/game': (_) => const Text('game'),
          '/puzzle': (_) => const Text('puzzle'),
          Routes.finish: (_) => const Text('finish'),
        },
      ));
      final nav = key.currentState;
      if (nav == null) throw StateError('no navigator');
      return nav;
    }

    testWidgets('closes the puzzle and puts the finish screen in the route\'s place', (tester) async {
      final nav = await app(tester);
      nav.pushNamed('/game');
      await tester.pumpAndSettle();
      final own = ModalRoute.of(tester.element(find.text('game')));
      nav.pushNamed('/puzzle');
      await tester.pumpAndSettle();
      expect(replaceWithFinish(nav, own, const {}), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('finish'), findsOneWidget);
      nav.pop();
      await tester.pumpAndSettle();
      expect(find.text('shell'), findsOneWidget, reason: 'back goes to the shell, which is still there');
    });

    testWidgets('a route that is already leaving changes nothing', (tester) async {
      final nav = await app(tester);
      nav.pushNamed('/game');
      await tester.pumpAndSettle();
      final own = ModalRoute.of(tester.element(find.text('game')));
      nav.pop();
      await tester.pump();
      expect(replaceWithFinish(nav, own, const {}), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('shell'), findsOneWidget);
      expect(find.text('finish'), findsNothing);
    });
  });

  group('FinishController', () {
    late StreamController<List<Team>> teams;
    late StreamController<Team> own;
    late List<int> saved;
    late bool failSave;

    FinishController make() {
      teams = StreamController<List<Team>>();
      own = StreamController<Team>();
      saved = [];
      failSave = false;
      return FinishController(
        event: _event,
        team: _team('Vulpile'),
        teams: teams.stream,
        teamStream: own.stream,
        saveRating: (stars) async {
          saved.add(stars);
          if (failSave) throw Exception('offline');
        },
        clock: () => DateTime(2026, 11, 14, 12),
      );
    }

    test('the place appears when the teams arrive', () async {
      final c = make();
      expect(c.place, isNull);
      teams.add([_team('Bufnițele', progress: 6), _team('Vulpile', progress: 6), _team('Lupii', progress: 2)]);
      await Future<void>.delayed(Duration.zero);
      expect(c.place?.teams, 3);
      expect(c.place?.place, isNotNull);
      expect(c.ranked, hasLength(3));
      c.dispose();
    });

    test('a rating is saved, and kept here even when the save fails', () async {
      final c = make();
      await c.rate(4);
      expect(saved, [4]);
      expect(c.rating, 4);
      failSave = true;
      await c.rate(5);
      expect(c.rating, 5);
      c.dispose();
    });

    test('the share text names the place once known', () async {
      final c = make();
      expect(c.shareText, isNot(contains('locul')));
      teams.add([_team('Vulpile', progress: 6)]);
      await Future<void>.delayed(Duration.zero);
      expect(c.shareText, contains('pe locul 1 din 1'));
      c.dispose();
    });

    test('a stopped game\'s time stops when the screen opens', () async {
      var now = DateTime(2026, 11, 14, 11);
      final c = FinishController(
        event: _event,
        team: Team.fromMap({'name': 'Vulpile', 'missionProgress': 3, 'hasFinished': true}),
        teams: const Stream.empty(),
        teamStream: const Stream.empty(),
        saveRating: (_) async {},
        clock: () => now,
      );
      final first = c.timePlayed;
      now = now.add(const Duration(minutes: 10));
      expect(c.timePlayed, first);
      expect(first, const Duration(hours: 1));
      c.dispose();
    });

    test('a fresher team doc replaces the one it opened with', () async {
      final c = make();
      own.add(_team('Vulpile', progress: 6, finished: true));
      await Future<void>.delayed(Duration.zero);
      expect(c.team.hasFinished, isTrue);
      c.dispose();
    });
  });
}
