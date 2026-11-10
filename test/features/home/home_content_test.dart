import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/home/logic/home_content.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/model/stire.dart';

final _now = DateTime(2026, 11, 20, 12);

Event _event(String id, {DateTime? start, EventType type = EventType.PUBLIC}) =>
    Event(eventId: id, name: id, dateEvent: start, type: type);

Memory _memory(DateTime? date) => Memory(eventId: 'e', eventName: 'Harta', date: date);

void main() {
  test('new player: no games and no XP', () {
    expect(isNewPlayer(0, 0), isTrue);
    expect(isNewPlayer(1, 0), isFalse);
    expect(isNewPlayer(0, 50), isFalse);
  });

  test('a memory goes first for 3 days', () {
    expect(memoryGoesFirst(_memory(_now.subtract(const Duration(days: 3))), _now), isTrue);
    expect(memoryGoesFirst(_memory(_now.subtract(const Duration(days: 3, minutes: 1))), _now), isFalse);
    expect(memoryGoesFirst(_memory(_now.subtract(const Duration(hours: 1))), _now), isTrue);
    expect(memoryGoesFirst(_memory(_now.add(const Duration(days: 1))), _now), isFalse);
    expect(memoryGoesFirst(_memory(null), _now), isFalse);
    expect(memoryGoesFirst(null, _now), isFalse);
  });

  group('the "nothing open" banner', () {
    test('shows when there is truly nothing', () {
      expect(showNothingOpen(const NoHero(), const []), isTrue);
    });

    test('not above events that are open', () {
      expect(showNothingOpen(const NoHero(), [_event('a')]), isFalse);
    });

    test('not with a main card', () {
      final event = _event('a');
      expect(showNothingOpen(RecommendedHero(event), const []), isFalse);
    });
  });

  group('new events', () {
    final a = _event('a');
    final b = _event('b');

    test('the recommended event is not repeated', () {
      expect(newEventsToShow([a, b], RecommendedHero(a)), [b]);
    });

    test('other heroes leave the list alone', () {
      expect(newEventsToShow([a, b], const NoHero()), [a, b]);
    });

    test('at most 4', () {
      final many = [for (var i = 0; i < 6; i++) _event('$i')];
      expect(newEventsToShow(many, const NoHero()).length, 4);
    });
  });

  group('past games', () {
    final old = _now.subtract(const Duration(days: 30));

    test('public and over', () {
      final shown = pastGamesToShow([
        _event('over', start: old),
        _event('private', start: old, type: EventType.PRIVAT),
        _event('running', start: _now.subtract(const Duration(hours: 1))),
      ], _now);
      expect(shown.map((e) => e.eventId), ['over']);
    });

    test('at most 4', () {
      final many = [for (var i = 0; i < 6; i++) _event('$i', start: old)];
      expect(pastGamesToShow(many, _now).length, 4);
    });
  });

  group('latest news', () {
    Stire stire(String id, DateTime? at) => Stire(id: id, title: id, publicationDate: at);

    test('newest first, without the future, undated last', () {
      final latest = latestNews([
        stire('old', _now.subtract(const Duration(days: 9))),
        stire('undated', null),
        stire('new', _now.subtract(const Duration(days: 1))),
        stire('future', _now.add(const Duration(days: 1))),
      ], _now);
      expect(latest.map((s) => s.id), ['new', 'old', 'undated']);
    });

    test('at most 5', () {
      final many = [for (var i = 0; i < 8; i++) stire('$i', _now.subtract(Duration(days: i)))];
      expect(latestNews(many, _now).map((s) => s.id), ['0', '1', '2', '3', '4']);
    });

    test('none', () {
      expect(latestNews(const [], _now), isEmpty);
      expect(latestNews([stire('future', _now.add(const Duration(days: 1)))], _now), isEmpty);
    });
  });

  group('season spot', () {
    const standings = [
      SeasonStanding(crewId: 'x', crewName: 'X', points: 300),
      SeasonStanding(crewId: 'y', crewName: 'Y', points: 200),
      SeasonStanding(crewId: 'mine', crewName: 'Vulpile', points: 135),
      SeasonStanding(crewId: 'z', crewName: 'Z', points: 100),
      SeasonStanding(crewId: 'other', crewName: 'Lupii', points: 60),
    ];

    test('the best-placed crew', () {
      final spot = seasonSpot(standings, {'other', 'mine'});
      expect(spot?.place, 3);
      expect(spot?.standing.crewName, 'Vulpile');
    });

    test('no crew in the list', () {
      expect(seasonSpot(standings, {'none'}), isNull);
      expect(seasonSpot(standings, const {}), isNull);
      expect(seasonSpot(const [], {'mine'}), isNull);
    });
  });
}
