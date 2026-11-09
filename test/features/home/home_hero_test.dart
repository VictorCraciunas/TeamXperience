import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

final _now = DateTime(2026, 10, 20, 12);

Event _event(
  String id, {
  DateTime? start,
  EventType type = EventType.PUBLIC,
  DateTime? enrollmentOpens,
  DateTime? enrollmentCloses,
  bool stopped = false,
}) {
  return Event(
    eventId: id,
    name: 'Eveniment $id',
    dateEvent: start,
    type: type,
    dateStartEnrollment: enrollmentOpens ?? _now.subtract(const Duration(days: 30)),
    dateDeadlineEnrollment: enrollmentCloses ?? _now.add(const Duration(days: 30)),
    isStopped: stopped,
  );
}

Team _team({bool started = false, bool finished = false}) {
  return Team(
    name: 'Vulturii',
    teamMembers: 'Ana, Dan',
    captainName: 'Ana',
    phoneNumber: '0712345678',
    captainEmail: 'ana@example.com',
    hasStarted: started,
    hasFinished: finished,
  );
}

HomeHero _resolve({
  Event? activeEvent,
  Team? activeTeam,
  Event? startedRecently,
  Team? startedRecentlyTeam,
  Event? finishedEvent,
  Team? finishedTeam,
  List<Event> registeredUpcoming = const [],
  List<Event> allEvents = const [],
  Set<String> registeredIds = const {},
}) {
  return resolveHomeHero(
    now: _now,
    activeEvent: activeEvent,
    activeTeam: activeTeam,
    startedRecently: startedRecently,
    startedRecentlyTeam: startedRecentlyTeam,
    finishedEvent: finishedEvent,
    finishedTeam: finishedTeam,
    registeredUpcoming: registeredUpcoming,
    allEvents: allEvents,
    registeredIds: registeredIds,
  );
}

void main() {
  signatureTests();
  recentlyStartedTests();
  final inOneHour = _now.add(const Duration(hours: 1));

  group('finished', () {
    final running = _event('run', start: _now.subtract(const Duration(minutes: 30)));

    test('a finished team sees that, not the start code', () {
      final hero = _resolve(finishedEvent: running, finishedTeam: _team(started: true, finished: true), startedRecently: running);
      expect(hero, isA<FinishedHero>());
      expect(hero.signature, 'finished:run');
    });

    test('another event\'s start code wins, so the player does not miss it', () {
      final other = _event('other', start: _now.subtract(const Duration(minutes: 5)));
      final hero = _resolve(finishedEvent: running, finishedTeam: _team(started: true, finished: true), startedRecently: other);
      expect(hero, isA<StartingSoonHero>());
      expect(hero.signature, 'soon:other');
    });

    test('the finished event is skipped when looking for a start code', () {
      final first = _event('first', start: _now.subtract(const Duration(minutes: 40)));
      final second = _event('second', start: _now.subtract(const Duration(minutes: 5)));
      expect(recentlyStartedEvent([first, second], _now)?.eventId, 'first');
      expect(recentlyStartedEvent([first, second], _now, except: 'first')?.eventId, 'second');
      expect(recentlyStartedEvent([first], _now, except: 'first'), isNull);
    });

    test('a game in play wins over a finished one', () {
      final hero = _resolve(
        activeEvent: _event('live', start: _now.subtract(const Duration(minutes: 10))),
        activeTeam: _team(started: true),
        finishedEvent: running,
        finishedTeam: _team(started: true, finished: true),
      );
      expect(hero, isA<LiveHero>());
    });

    test('an event that is over is not "finished" any more', () {
      final over = _event('over', start: _now.subtract(const Duration(hours: 4)));
      final next = _event('next', start: inOneHour);
      final hero = _resolve(finishedEvent: over, finishedTeam: _team(started: true, finished: true), registeredUpcoming: [next]);
      expect(hero, isA<UpcomingHero>());
    });
  });

  group('live', () {
    test('a started, unfinished team in a running event wins over everything', () {
      final live = _event('live', start: _now.subtract(const Duration(minutes: 30)));
      final hero = _resolve(
        activeEvent: live,
        activeTeam: _team(started: true),
        registeredUpcoming: [_event('next', start: inOneHour)],
        allEvents: [_event('rec', start: inOneHour)],
      );
      expect(hero, isA<LiveHero>());
      expect((hero as LiveHero).event.eventId, 'live');
    });

    test('a stopped event is never live', () {
      final stopped = _event('s', start: _now.subtract(const Duration(minutes: 30)), stopped: true);
      final hero = _resolve(
        activeEvent: stopped,
        activeTeam: _team(started: true),
        registeredUpcoming: [_event('next', start: inOneHour)],
      );
      expect(hero, isA<UpcomingHero>());
    });

    test('an event past the 3 hour mark is never live', () {
      final old = _event('old', start: _now.subtract(const Duration(hours: 4)));
      expect(_resolve(activeEvent: old, activeTeam: _team(started: true)), isA<NoHero>());
    });

    test('a finished team is not live', () {
      final event = _event('e', start: _now.subtract(const Duration(minutes: 30)));
      expect(
        _resolve(activeEvent: event, activeTeam: _team(started: true, finished: true)),
        isA<NoHero>(),
      );
    });

    test('an active event without a team is not live', () {
      final event = _event('e', start: _now.subtract(const Duration(minutes: 30)));
      expect(_resolve(activeEvent: event), isA<NoHero>());
    });
  });

  group('starting soon', () {
    test('started 10 minutes ago and the team has not started: 50 minutes left', () {
      final event = _event('e', start: _now.subtract(const Duration(minutes: 10)));
      final hero = _resolve(startedRecently: event, startedRecentlyTeam: _team());
      expect(hero, isA<StartingSoonHero>());
      expect((hero as StartingSoonHero).minutesLeftToEnter, 50);
    });

    test('a 30-minute window: 20 minutes left 10 minutes after the start', () {
      final event = _event('e', start: _now.subtract(const Duration(minutes: 10)))..enterWindowMinutes = 30;
      final hero = _resolve(startedRecently: event, startedRecentlyTeam: _team());
      expect((hero as StartingSoonHero).minutesLeftToEnter, 20);
    });

    test('a 30-minute window is closed 31 minutes after the start', () {
      final event = _event('e', start: _now.subtract(const Duration(minutes: 31)))..enterWindowMinutes = 30;
      expect(recentlyStartedEvent([event], _now), isNull);
    });

    test('works when the team is not known yet', () {
      final event = _event('e', start: _now.subtract(const Duration(minutes: 10)));
      expect(_resolve(startedRecently: event), isA<StartingSoonHero>());
    });

    test('started 61 minutes ago falls through', () {
      final event = _event('e', start: _now.subtract(const Duration(minutes: 61)));
      expect(_resolve(startedRecently: event), isA<NoHero>());
    });

    test('a team that already started does not get the enter code state', () {
      final event = _event('e', start: _now.subtract(const Duration(minutes: 10)));
      expect(
        _resolve(startedRecently: event, startedRecentlyTeam: _team(started: true)),
        isA<NoHero>(),
      );
    });

    test('a stopped event is skipped', () {
      final event = _event('e', start: _now.subtract(const Duration(minutes: 10)), stopped: true);
      expect(_resolve(startedRecently: event), isA<NoHero>());
    });
  });

  group('upcoming', () {
    test('the nearest registered future event, with the time until it starts', () {
      final far = _event('far', start: _now.add(const Duration(days: 5)));
      final near = _event('near', start: _now.add(const Duration(days: 2, hours: 3)));
      final hero = _resolve(registeredUpcoming: [far, near]);
      expect(hero, isA<UpcomingHero>());
      expect((hero as UpcomingHero).event.eventId, 'near');
      expect(hero.untilStart, const Duration(days: 2, hours: 3));
    });

    test('events in the past or without a date are ignored', () {
      final past = _event('past', start: _now.subtract(const Duration(days: 1)));
      final undated = _event('undated');
      expect(_resolve(registeredUpcoming: [past, undated]), isA<NoHero>());
    });
  });

  group('recommended', () {
    test('picks the earliest public event with open enrollment', () {
      final later = _event('later', start: _now.add(const Duration(days: 10)));
      final sooner = _event('sooner', start: _now.add(const Duration(days: 4)));
      final hero = _resolve(allEvents: [later, sooner]);
      expect(hero, isA<RecommendedHero>());
      expect((hero as RecommendedHero).event.eventId, 'sooner');
    });

    test('a private event is never recommended', () {
      final private = _event('p', start: inOneHour, type: EventType.PRIVAT);
      expect(_resolve(allEvents: [private]), isA<NoHero>());
    });

    test('enrollment that has not opened or has closed is skipped', () {
      final notOpen = _event('a', start: inOneHour, enrollmentOpens: _now.add(const Duration(days: 1)));
      final closed = _event('b', start: inOneHour, enrollmentCloses: _now.subtract(const Duration(days: 1)));
      expect(_resolve(allEvents: [notOpen, closed]), isA<NoHero>());
    });

    test('an already registered event is skipped', () {
      final event = _event('mine', start: inOneHour);
      expect(_resolve(allEvents: [event], registeredIds: {'mine'}), isA<NoHero>());
    });

    test('events in the past or without a date are skipped', () {
      final past = _event('past', start: _now.subtract(const Duration(days: 1)));
      final undated = _event('undated');
      expect(_resolve(allEvents: [past, undated]), isA<NoHero>());
    });
  });

  test('upcoming wins over recommended', () {
    final hero = _resolve(
      registeredUpcoming: [_event('mine', start: _now.add(const Duration(days: 3)))],
      allEvents: [_event('rec', start: inOneHour)],
    );
    expect(hero, isA<UpcomingHero>());
  });

  test('nothing available gives no hero', () {
    expect(_resolve(), isA<NoHero>());
  });
}

void recentlyStartedTests() {
  final now = DateTime(2026, 10, 20, 12);
  Event at(String id, Duration ago, {bool stopped = false}) => Event(
        eventId: id,
        name: id,
        dateEvent: now.subtract(ago),
        isStopped: stopped,
      );

  group('recentlyStartedEvent', () {
    test('picks the oldest event inside the entry window', () {
      final result = recentlyStartedEvent(
        [at('b', const Duration(minutes: 10)), at('a', const Duration(minutes: 40))],
        now,
      );
      expect(result?.eventId, 'a');
    });

    test('ignores future, expired and stopped events', () {
      final result = recentlyStartedEvent(
        [
          at('future', const Duration(minutes: -5)),
          at('old', const Duration(minutes: 90)),
          at('stopped', const Duration(minutes: 5), stopped: true),
        ],
        now,
      );
      expect(result, isNull);
    });
  });
}

void signatureTests() {
  group('HomeHero.signature', () {
    test('the same kind for the same event has the same signature', () {
      final a = UpcomingHero(_event('a', start: _now.add(const Duration(days: 2))), const Duration(days: 2));
      final b = UpcomingHero(_event('a', start: _now.add(const Duration(days: 2))), const Duration(days: 1, hours: 23));
      expect(a.signature, b.signature);
    });

    test('a different kind or a different event changes it', () {
      final event = _event('a', start: _now.add(const Duration(days: 2)));
      final upcoming = UpcomingHero(event, const Duration(days: 2));
      expect(upcoming.signature, isNot(RecommendedHero(event).signature));
      expect(upcoming.signature, isNot(UpcomingHero(_event('b', start: _now), Duration.zero).signature));
    });

    test('no hero has its own signature', () {
      expect(const NoHero().signature, isNot(RecommendedHero(_event('a', start: _now)).signature));
    });
  });
}
