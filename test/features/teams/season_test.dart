import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/shell/logic/user_doc_watch.dart';
import 'package:teamxperience/features/teams/logic/season_rows.dart';
import 'package:teamxperience/features/teams/widgets/crew_card.dart';
import 'package:teamxperience/features/teams/widgets/season_leaderboard.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/model/crew_stats.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../../ui/pump_ui.dart';

const _a = SeasonStanding(crewId: 'c1', crewName: 'Bufnițele', points: 240);
const _b = SeasonStanding(crewId: 'c2', crewName: 'Vulpile', points: 175);

Crew _crew({CrewStats stats = const CrewStats()}) => Crew(
      id: 'c2',
      name: 'Vulpile',
      captainUid: 'u1',
      memberUids: const ['u1'],
      members: const [TeamMember(uid: 'u1', displayName: 'Ana Pop', initials: 'AP')],
      inviteCode: 'VLP482',
      stats: stats,
    );

void main() {
  group('CrewStats', () {
    test('reads the map', () {
      final stats = CrewStats.fromMap({'games': 3, 'wins': 1, 'distanceMeters': 31000});
      expect((stats.games, stats.wins, stats.distanceMeters), (3, 1, 31000.0));
    });

    test('a crew from before them has zeros', () {
      expect(CrewStats.fromMap(null).games, 0);
      expect(CrewStats.fromMap({'games': 'x'}).games, 0);
      final crew = Crew.fromMap('c', {'name': 'A'});
      expect(crew.stats.wins, 0);
    });

    test('Crew.fromMap reads them', () {
      expect(Crew.fromMap('c', {'stats': {'games': 2}}).stats.games, 2);
    });
  });

  group('SeasonStanding', () {
    test('reads the map, whole numbers or not', () {
      final s = SeasonStanding.fromMap('c1', {'crewName': 'Vulpile', 'points': 100.0, 'games': 2});
      expect((s.crewId, s.crewName, s.points, s.games), ('c1', 'Vulpile', 100, 2));
    });

    test('an odd document does not throw', () {
      final s = SeasonStanding.fromMap('c1', {'points': 'many'});
      expect((s.crewName, s.points), ('', 0));
    });
  });

  group('seasonOf: the same calendar as the results function', () {
    final cases = <(DateTime, String, String)>[
      (DateTime(2026, 3, 1), '2026-spring', 'Primăvara 2026'),
      (DateTime(2026, 5, 31), '2026-spring', 'Primăvara 2026'),
      (DateTime(2026, 6, 1), '2026-summer', 'Vara 2026'),
      (DateTime(2026, 9, 1), '2026-autumn', 'Toamna 2026'),
      (DateTime(2026, 11, 30), '2026-autumn', 'Toamna 2026'),
      (DateTime(2026, 12, 1), '2026-winter', 'Iarna 2026'),
      (DateTime(2027, 1, 15), '2026-winter', 'Iarna 2026'),
      (DateTime(2027, 2, 28), '2026-winter', 'Iarna 2026'),
    ];
    for (final (date, id, name) in cases) {
      test('$date', () {
        final season = seasonOf(date);
        expect((season.id, season.name), (id, name));
      });
    }
  });

  group('seasonRows', () {
    test('places in order, points, own crew', () {
      final rows = seasonRows(const [_a, _b], const {'c2'});
      expect(rows.map((r) => (r.place, r.name, r.score, r.own)), [
        (1, 'Bufnițele', '240 p', false),
        (2, 'Vulpile', '175 p', true),
      ]);
    });

    test('the labels agree', () {
      expect((gamesLabel(1), gamesLabel(3)), ('joc', 'jocuri'));
      expect((winsLabel(1), winsLabel(0)), ('victorie', 'victorii'));
    });
  });

  group('SeasonLeaderboard', () {
    testWidgets('the mockup', (tester) async {
      await pumpUi(tester, const SeasonLeaderboard(seasonName: 'Toamna 2026', standings: [_a, _b], myCrewIds: {'c2'}));
      expect(find.text('Clasamentul sezonului'), findsOneWidget);
      expect(find.text('Toamna 2026'), findsOneWidget);
      expect(find.textContaining('Bufnițele'), findsOneWidget);
      expect(find.text('175 p'), findsOneWidget);
    });

    testWidgets('empty says when it starts', (tester) async {
      await pumpUi(tester, const SeasonLeaderboard(seasonName: 'Toamna 2026', standings: [], myCrewIds: {}));
      expect(find.text('Clasamentul începe după primul joc.'), findsOneWidget);
    });

    for (final theme in [AppTheme.light, AppTheme.dark]) {
      testWidgets('fits 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
        await pumpUi(
          tester,
          const SeasonLeaderboard(
            seasonName: 'Primăvara 2026',
            standings: [SeasonStanding(crewId: 'c', crewName: 'Alexandru-Constantin și Prietenii de la Sibiu', points: 12345)],
            myCrewIds: {'c'},
          ),
          theme: theme,
          width: 320,
          textScale: 1.3,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('CrewCard', () {
    Widget card(Crew crew) => CrewCard(crew: crew, onShare: () {}, onCopy: () {});

    testWidgets('the mockup: games, wins, km together', (tester) async {
      await pumpUi(tester, card(_crew(stats: const CrewStats(games: 3, wins: 1, distanceMeters: 31000))));
      for (final text in ['3', 'jocuri', '1', 'victorie', '31 km', 'împreună']) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('a new crew shows zeros', (tester) async {
      await pumpUi(tester, card(_crew()));
      expect(find.text('victorii'), findsOneWidget);
      expect(find.text('0 km'), findsOneWidget);
    });

    testWidgets('fits 320 px at 1.3x text', (tester) async {
      await pumpUi(tester, card(_crew(stats: const CrewStats(games: 1234, wins: 999, distanceMeters: 1234000))), width: 320, textScale: 1.3);
      expect(tester.takeException(), isNull);
    });
  });

  group('UserDocWatch', () {
    AppUser user(String uid) => AppUser(
          email: 'a@b.ro',
          firstName: 'A',
          lastName: 'B',
          uid: uid,
          role: Role.USER,
          registeredEventIds: const [],
          fcmToken: '',
        );

    test('passes fresh users on, ignores a missing document and errors, stops when cancelled', () async {
      final stream = StreamController<AppUser?>();
      final seen = <String>[];
      final watch = UserDocWatch(stream.stream, (fresh) => seen.add(fresh.uid));
      stream.add(user('a'));
      stream.add(null);
      stream.addError(Exception('offline'));
      stream.add(user('b'));
      await Future<void>.delayed(Duration.zero);
      expect(seen, ['a', 'b']);
      watch.cancel();
      await Future<void>.delayed(Duration.zero);
      expect(stream.hasListener, isFalse);
    });
  });
}
