import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_see_registered_teams/event_registered_teams_controller.dart';
import 'package:teamxperience/features/live_room/controller/live_room_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

Team _team(String name, {String phone = '0722 123 456', int joined = 1, int size = 4, String member = ''}) => Team(
      name: name,
      teamMembers: member,
      captainName: '',
      phoneNumber: phone,
      captainEmail: '',
      userIds: [for (var i = 0; i < joined; i++) '$name$i'],
      numberOfMembers: size,
    );

void main() {
  final event = Event(eventId: 'e');

  Future<EventRegisteredTeamsController> loaded(
    List<Team> teams, {
    Future<void> Function(String eventId, Team team)? delete,
    Future<bool> Function(Uri uri)? openPhone,
  }) async {
    final c = EventRegisteredTeamsController(
      event,
      load: (_) async => teams,
      delete: delete ?? (_, __) async {},
      openPhone: openPhone,
    );
    await c.loadTeams();
    return c;
  }

  test('the search narrows the list and tells the screen', () async {
    final c = await loaded([_team('Vulpile'), _team('Bufnițele', member: 'Ana Pop')]);
    var told = 0;
    c.addListener(() => told++);

    c.setSearch('bufnite');
    expect(c.visibleTeams.map((t) => t.name), ['Bufnițele']);
    c.setSearch('ana');
    expect(c.visibleTeams.map((t) => t.name), ['Bufnițele']);
    c.setSearch('');
    expect(c.visibleTeams.length, 2);
    expect(told, 3);
  });

  test('the stats count every team, whatever the search', () async {
    final c = await loaded([_team('A', joined: 4, size: 4), _team('B', joined: 2, size: 4)]);
    c.setSearch('A');
    expect((c.stats.teams, c.stats.players, c.stats.incomplete), (2, 6, 1));
  });

  test('one team open at a time; a second tap closes it', () async {
    final a = _team('A');
    final b = _team('B');
    final c = await loaded([a, b]);
    expect(c.isExpanded(a), isFalse);

    c.toggle(a);
    expect((c.isExpanded(a), c.isExpanded(b)), (true, false));
    c.toggle(b);
    expect((c.isExpanded(a), c.isExpanded(b)), (false, true));
    c.toggle(b);
    expect(c.isExpanded(b), isFalse);
  });

  test('removing a team deletes it, drops it from the list and closes it', () async {
    final deleted = <String>[];
    final a = _team('A');
    final c = await loaded([a, _team('B')], delete: (eventId, team) async => deleted.add('$eventId/${team.name}'));
    c.toggle(a);

    await c.deleteTeam(a);
    expect(deleted, ['e/A']);
    expect(c.teams.map((t) => t.name), ['B']);
    expect(c.isExpanded(a), isFalse);
  });

  test('a failed delete keeps the team and passes the error on', () async {
    final a = _team('A');
    final c = await loaded([a], delete: (_, __) async => throw Exception('offline'));
    await expectLater(c.deleteTeam(a), throwsException);
    expect(c.teams.length, 1);
  });

  test('calling the captain opens the phone on the digits', () async {
    final opened = <Uri>[];
    final c = await loaded([], openPhone: (uri) async {
      opened.add(uri);
      return true;
    });
    final team = _team('A', phone: '0722 123 456');
    expect(c.canCall(team), isTrue);
    expect(await c.callCaptain(team), CallResult.opened);
    expect(opened.single.toString(), 'tel:0722123456');
  });

  test('no number: no call; a phone that will not open says so', () async {
    final c = await loaded([], openPhone: (_) async => false);
    final none = _team('A', phone: ' ');
    expect(c.canCall(none), isFalse);
    expect(await c.callCaptain(none), CallResult.noPhone);
    expect(await c.callCaptain(_team('B')), CallResult.failed);
  });

  test('members joined from the members list count, not only typed names', () async {
    final team = Team(
      name: 'A',
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      members: const [TeamMember(uid: 'u1', displayName: 'Radu Marin', initials: 'RM')],
    );
    final c = await loaded([team]);
    c.setSearch('radu');
    expect(c.visibleTeams.single.name, 'A');
  });
}
