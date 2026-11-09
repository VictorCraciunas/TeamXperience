import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/hero_from_providers.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';

final _now = DateTime(2026, 11, 14, 11);

class _Events extends Fake implements EventList {
  @override
  List<Event> get events => const [];
}

class _UserEvents extends Fake implements UserEventsProvider {
  _UserEvents({this.finishedEvent, this.finishedTeam, this.upcomingRegisteredEvents = const []});

  @override
  final Event? finishedEvent;
  @override
  final Team? finishedTeam;
  @override
  final List<Event> upcomingRegisteredEvents;
  @override
  List<Event> get registeredEvents => upcomingRegisteredEvents;
  @override
  Event? get activeEvent => null;
  @override
  Team? get activeTeam => null;
  @override
  Event? get recentlyStartedEvent => null;
}

void main() {
  final finished = Event(eventId: 'a', dateEvent: _now.subtract(const Duration(hours: 1)));
  final next = Event(eventId: 'b', dateEvent: _now.add(const Duration(days: 2)));
  final team = Team.fromMap(const {'name': 'Vulpile', 'hasStarted': true, 'hasFinished': true});
  final userEvents = _UserEvents(finishedEvent: finished, finishedTeam: team, upcomingRegisteredEvents: [next]);

  test('Home says the team finished', () {
    final hero = heroFromProviders(userEvents: userEvents, eventList: _Events(), now: _now);
    expect(hero, isA<FinishedHero>());
  });

  test('Joacă still knows the next game of a player who finished another', () {
    final hero = heroFromProviders(userEvents: userEvents, eventList: _Events(), now: _now, includeFinished: false);
    expect(playTabState(hero), isA<PlayNext>());
  });
}
