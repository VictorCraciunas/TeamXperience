import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_status.dart';
import 'package:teamxperience/features/event_details/logic/event_menu_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

final _now = DateTime(2026, 11, 21, 12);

Event _event({DateTime? start, bool stopped = false, EventStatus status = EventStatus.published}) => Event(
      eventId: 'e1',
      name: 'Moștenirea Cartografului',
      dateEvent: start,
      durationMinutes: 120,
      isStopped: stopped,
      status: status,
    );

Team _team(String name, {int members = 0, String typed = '', String? unread}) => Team(
      name: name,
      teamMembers: typed,
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      members: [for (var i = 0; i < members; i++) TeamMember.fromName('Jucător $i')],
      unreadText: unread,
    );

void main() {
  group('eventStateWord', () {
    test('a draft says ciornă, whatever the date', () {
      expect(eventStateWord(_event(status: EventStatus.draft, start: _now), _now), 'ciornă');
    });

    test('a stopped event says oprit', () {
      expect(eventStateWord(_event(start: _now.add(const Duration(days: 1)), stopped: true), _now), 'oprit');
    });

    test('past its duration says încheiat', () {
      expect(eventStateWord(_event(start: _now.subtract(const Duration(hours: 3))), _now), 'încheiat');
    });

    test('started and not over says în desfășurare', () {
      expect(eventStateWord(_event(start: _now.subtract(const Duration(minutes: 30))), _now), 'în desfășurare');
      expect(eventStateWord(_event(start: _now), _now), 'în desfășurare');
    });

    test('before the start, or with no date, says publicat', () {
      expect(eventStateWord(_event(start: _now.add(const Duration(days: 2))), _now), 'publicat');
      expect(eventStateWord(_event(), _now), 'publicat');
    });
  });

  test('registeredTeamsCount follows Romanian plurals', () {
    expect(registeredTeamsCount(0), 'Nicio echipă înscrisă');
    expect(registeredTeamsCount(1), 'O echipă înscrisă');
    expect(registeredTeamsCount(12), '12 echipe înscrise');
    expect(registeredTeamsCount(20), '20 de echipe înscrise');
    expect(registeredTeamsCount(101), '101 echipe înscrise');
  });

  test('eventMenuHeadline joins the count and the state', () {
    expect(eventMenuHeadline(_event(start: _now.add(const Duration(days: 2))), 12, _now), '12 echipe înscrise · publicat');
  });

  test('registeredTeamsLine counts teams and players', () {
    expect(registeredTeamsLine(12, 46), '12 echipe · 46 de jucători');
    expect(registeredTeamsLine(12, 19), '12 echipe · 19 jucători');
    expect(registeredTeamsLine(1, 1), 'O echipă · un jucător');
    expect(registeredTeamsLine(2, 0), '2 echipe · niciun jucător');
    expect(registeredTeamsLine(25, 120), '25 de echipe · 120 de jucători');
    expect(registeredTeamsLine(0, 0), 'Nicio echipă încă');
  });

  test('playersOf adds members, and old teams by their typed names', () {
    final teams = [_team('A', members: 3), _team('B', typed: 'Ana, Ion'), _team('C')];
    expect(playersOf(teams), 5);
    expect(playersOf(const []), 0);
  });

  test('unreadConversations counts teams with an unread message', () {
    final teams = [_team('A', unread: 'Salut'), _team('B'), _team('C', unread: 'Gata')];
    expect(unreadConversations(teams), 2);
  });
}
