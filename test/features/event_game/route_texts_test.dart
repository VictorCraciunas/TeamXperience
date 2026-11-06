import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_game/logic/route_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/model/team.dart';

void main() {
  test('the place line', () {
    expect(placeLine('Vulpile', 2, 12), 'Vulpile · locul 2 din 12');
  });

  group('placeOf', () {
    Team team(String name, int progress) => Team(
          name: name,
          teamMembers: '',
          captainName: '',
          phoneNumber: '',
          captainEmail: '',
          missionProgress: progress,
        );

    test("the team's place among every team", () {
      final teams = [team('Bufnițele', 4), team('Vulpile', 3), team('Lupii', 1)];
      expect(placeOf(teams, 'Vulpile', 6), (place: 2, teams: 3));
      expect(placeOf(teams, 'Bufnițele', 6), (place: 1, teams: 3));
    });

    test('null when the team is not among them', () {
      expect(placeOf([team('Lupii', 1)], 'Vulpile', 6), isNull);
      expect(placeOf([], 'Vulpile', 6), isNull);
    });
  });

  group('playedClock', () {
    final now = DateTime(2026, 11, 14, 10, 42, 18);

    test('from when the team started', () {
      expect(playedClock(DateTime(2026, 11, 14, 10), DateTime(2026, 11, 14, 9, 55), now), '0:42:18');
    });

    test('from the event start before the team\'s start time is known', () {
      expect(playedClock(null, DateTime(2026, 11, 14, 10, 30), now), '0:12:18');
    });

    test('zero before the start, and with no start at all', () {
      expect(playedClock(DateTime(2026, 11, 14, 11), null, now), '0:00:00');
      expect(playedClock(null, null, now), '0:00:00');
    });
  });

  group('leftClock', () {
    test('until the game closes, three hours after the start', () {
      final event = Event(eventId: 'e1', dateEvent: DateTime(2026, 11, 14, 10));
      expect(leftClock(event, DateTime(2026, 11, 14, 11, 42, 18)), '1:17:42');
    });

    test('never negative, and zero without a start', () {
      expect(leftClock(Event(eventId: 'e1', dateEvent: DateTime(2026, 11, 14, 10)), DateTime(2026, 11, 14, 14)), '0:00:00');
      expect(leftClock(Event(eventId: 'e1'), DateTime(2026, 11, 14, 14)), '0:00:00');
    });
  });

  group('missionPoint', () {
    test('the mission\'s own place first', () {
      final mission = Mission(id: '0', latitude: 45.79, longitude: 24.15, puzzles: [
        Puzzle(id: '0', type: PuzzleType.geolocation, latitude: 1, longitude: 2),
      ]);
      expect(missionPoint(mission), (lat: 45.79, lng: 24.15));
    });

    test('else its first location puzzle with both coordinates', () {
      final mission = Mission(id: '0', puzzles: [
        Puzzle(id: '0', type: PuzzleType.code),
        Puzzle(id: '1', type: PuzzleType.geolocation, latitude: 3),
        Puzzle(id: '2', type: PuzzleType.geolocation, latitude: 45.8, longitude: 24.1),
      ]);
      expect(missionPoint(mission), (lat: 45.8, lng: 24.1));
    });

    test('else nothing', () {
      expect(missionPoint(Mission(id: '0', puzzles: [Puzzle(id: '0', type: PuzzleType.code)])), isNull);
      expect(missionPoint(Mission(id: '0', latitude: 45.79)), isNull);
    });
  });

  group('distance', () {
    test('metres, rounded to ten', () {
      expect(distanceText(183), 'la 180 m de tine');
      expect(distanceText(996), 'la 1,0 km de tine');
    });

    test('a kilometre and up, with one decimal and a comma', () {
      expect(distanceText(1000), 'la 1,0 km de tine');
      expect(distanceText(1234), 'la 1,2 km de tine');
    });

    test('closer than 20 m is "aici"', () {
      expect(distanceText(0), 'chiar aici');
      expect(distanceText(19), 'chiar aici');
    });

    test('between two points', () {
      final line = distanceLine((lat: 45.7971, lng: 24.1520), (lat: 45.7983, lng: 24.1522));
      expect(line, matches(RegExp(r'^la \d+ m de tine$')));
    });

    test('no line without both points, or before the team has a position', () {
      expect(distanceLine(null, (lat: 45.79, lng: 24.15)), isNull);
      expect(distanceLine((lat: 45.79, lng: 24.15), null), isNull);
      expect(distanceLine((lat: 0, lng: 0), (lat: 45.79, lng: 24.15)), isNull);
    });
  });

  test('locked missions in one label', () {
    expect(lockedLabel([6]), '6');
    expect(lockedLabel([5, 6]), '5 · 6');
    expect(lockedLabel([5, 6, 7]), '5 · 6 · 7');
    expect(lockedLabel([5, 6, 7, 8]), '5–8');
    expect(lockedLabel([]), '');
  });
}
