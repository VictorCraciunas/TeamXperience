import 'dart:async';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/play_tab/controller/play_popup_controller.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';

final _now = DateTime(2026, 11, 10, 12);

class _Events extends Fake with ChangeNotifier implements EventList {
  List<Event> list = const [];
  @override
  List<Event> get events => list;
}

class _UserEvents extends Fake with ChangeNotifier implements UserEventsProvider {
  List<Event> upcoming = const [];
  Event? active;
  Team? team;
  @override
  List<Event> get upcomingRegisteredEvents => upcoming;
  @override
  List<Event> get registeredEvents => [...upcoming, if (active case final a?) a];
  @override
  Event? get activeEvent => active;
  @override
  Team? get activeTeam => team;
  @override
  Event? get recentlyStartedEvent => null;
  @override
  Event? get finishedEvent => null;
  @override
  Team? get finishedTeam => null;
  void changed() => notifyListeners();
}

Team _team(String name, {bool started = false, int progress = 0}) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      hasStarted: started,
      missionProgress: progress,
    );

Event _public(String id, int days) =>
    Event(eventId: id, type: EventType.PUBLIC, dateEvent: _now.add(Duration(days: days)));

void main() {
  late _Events events;
  late _UserEvents userEvents;
  late Completer<Team?> teamFetch;
  late StreamController<List<Team>> teams;
  late List<String> watched;
  late DateTime clock;

  PlayPopupController make() => PlayPopupController(
        userEvents: userEvents,
        eventList: events,
        teamFor: (_) => teamFetch.future,
        teams: (id) {
          watched.add(id);
          return teams.stream;
        },
        countTeams: (_) async => 9,
        clock: () => clock,
        random: Random(3),
      );

  setUp(() {
    events = _Events();
    userEvents = _UserEvents();
    teamFetch = Completer<Team?>();
    teams = StreamController<List<Team>>.broadcast();
    watched = [];
    clock = _now;
  });

  test('opens, ticks every second while open, and stops once closed', () {
    fakeAsync((async) {
      final c = make();
      var notes = 0;
      c.addListener(() => notes++);
      c.open();
      expect(c.isOpen, isTrue);
      notes = 0;
      async.elapse(const Duration(seconds: 3));
      expect(notes, 3);
      c.requestClose();
      expect((c.isOpen, c.isClosing), (true, true));
      c.closed();
      expect((c.isOpen, c.isClosing), (false, false));
      notes = 0;
      async.elapse(const Duration(seconds: 3));
      expect(notes, 0);
      c.dispose();
    });
  });

  test('toggle opens, then asks to close', () {
    final c = make();
    c.toggle();
    expect(c.isOpen, isTrue);
    c.toggle();
    expect(c.isClosing, isTrue);
    c.dispose();
  });

  test('the next game fetches its team once it opens', () async {
    final next = Event(eventId: 'n', dateEvent: _now.add(const Duration(days: 3)));
    userEvents.upcoming = [next];
    final c = make()..open();
    expect(c.state, isA<PlayNext>());
    expect(c.team, isNull);
    teamFetch.complete(_team('Vulpile'));
    await Future<void>.delayed(Duration.zero);
    expect(c.team?.name, 'Vulpile');
    c.dispose();
  });

  test('a live game follows the teams and stops when closed', () async {
    final live = Event(eventId: 'l', nrMissions: 6, dateEvent: _now.subtract(const Duration(minutes: 30)));
    userEvents
      ..active = live
      ..team = _team('Vulpile', started: true);
    final c = make()..open();
    expect(c.state, isA<PlayLive>());
    expect(watched, ['l']);
    teams.add([_team('Vulpile', started: true, progress: 3), _team('Bufnițele', started: true, progress: 4)]);
    await Future<void>.delayed(Duration.zero);
    expect(c.ranked.map((r) => r.team.name), ['Bufnițele', 'Vulpile']);
    expect(c.team?.missionProgress, 3);
    c.closed();
    expect(teams.hasListener, isFalse);
    c.dispose();
  });

  test('not registered: the first suggestion, then a different random one', () async {
    events.list = [_public('b', 5), _public('a', 2), _public('c', 9)];
    final c = make()..open();
    expect(c.state, isA<PlayNone>());
    expect(c.suggestions.map((e) => e.eventId), ['a', 'b', 'c']);
    expect((c.suggestionIndex, c.rerolled), (0, false));
    await Future<void>.delayed(Duration.zero);
    expect(c.teamCount(c.suggestions.first), 9);
    c.reroll();
    expect(c.suggestionIndex, isNot(0));
    expect(c.rerolled, isTrue);
    c.dispose();
  });

  test('a change in the providers while open changes the card', () {
    final c = make()..open();
    expect(c.state, isA<PlayNone>());
    var notes = 0;
    c.addListener(() => notes++);
    userEvents
      ..upcoming = [Event(eventId: 'n', dateEvent: _now.add(const Duration(days: 1)))]
      ..changed();
    expect(notes, greaterThan(0));
    expect(c.state, isA<PlayNext>());
    c.dispose();
  });
}
