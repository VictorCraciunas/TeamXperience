import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/events_tab/controller/events_tab_controller.dart';
import 'package:teamxperience/features/events_tab/logic/event_filters.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

class _FakeTeams extends Fake implements TeamService {
  final lookups = <String>[];
  final counted = <String>[];

  @override
  Future<Team?> getUserTeamForEvent(String eventId, String userId) async {
    lookups.add(eventId);
    if (eventId == 'muzee') throw Exception('offline');
    return Team(name: 'Vulpile', teamMembers: '', captainName: 'V', phoneNumber: '', captainEmail: '', numberOfMembers: 4);
  }

  @override
  Future<int> countTeams(String eventId) async {
    counted.add(eventId);
    return 10;
  }
}

class _Source extends ChangeNotifier {
  void ping() => notifyListeners();
}

EventsTabController _controller(_FakeTeams teams, _Source source, Set<String> registered) => EventsTabController(
      events: () => [sampleEvent(), ...sampleOpenEvents()],
      registeredIds: () => registered,
      uid: () => 'u1',
      source: source,
      teams: teams,
      clock: () => DateTime(2026, 11, 11, 12),
    );

void main() {
  test('looks up team names for registered events and counts for capped events, once each', () async {
    final teams = _FakeTeams();
    final source = _Source();
    final c = _controller(teams, source, {'sample', 'muzee'});
    await pumpEventQueue();
    expect(c.teamNames, {'sample': 'Vulpile'});
    expect(c.teamCounts, {'cerber': 10});
    source.ping();
    await pumpEventQueue();
    expect([...teams.lookups]..sort(), ['muzee', 'sample']);
    expect(teams.counted, ['cerber']);
    c.dispose();
  });

  test('filters, search and mode change what the tab shows', () async {
    final c = _controller(_FakeTeams(), _Source(), {'sample'});
    expect(c.sections.open.map((e) => e.eventId), ['cerber', 'muzee']);
    c.toggle(EventFilter.easy);
    expect(c.sections.open.map((e) => e.eventId), ['muzee']);
    c.toggle(EventFilter.easy);
    expect(c.query.isAll, isTrue);
    c.setSearch('cerber');
    expect(c.sections.open.map((e) => e.eventId), ['cerber']);
    c.selectAll();
    expect(c.query.isAll, isTrue);
    c.setMapMode(true);
    expect(c.mapMode, isTrue);
    c.toggleSearch();
    expect(c.searching, isTrue);
    c.dispose();
  });
}
