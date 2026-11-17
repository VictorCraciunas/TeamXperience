import 'package:teamxperience/features/live_room/logic/live_texts.dart' show teamInitial;
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_see_registered_teams/logic/registered_teams_texts.dart';
import 'package:teamxperience/features/event_see_registered_teams/logic/team_members.dart';
import 'package:teamxperience/features/event_see_registered_teams/logic/team_search.dart';
import 'package:teamxperience/features/event_see_registered_teams/logic/team_stats.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

Team _team({
  String name = 'Vulpile',
  int joined = 2,
  int size = 4,
  List<TeamMember> members = const [],
  String typed = '',
  String captainName = 'Radu Marin',
  String? captainUid,
  String phone = '0722 123 456',
  String email = 'radu@email.ro',
}) =>
    Team(
      name: name,
      teamMembers: typed,
      captainName: captainName,
      phoneNumber: phone,
      captainEmail: email,
      userIds: [for (var i = 0; i < joined; i++) 'u$i'],
      numberOfMembers: size,
      members: members,
      captainUid: captainUid,
    );

TeamMember _m(String uid, String name, [String initials = '']) =>
    TeamMember(uid: uid, displayName: name, initials: initials);

void main() {
  group('teamStats', () {
    test('counts teams, joined players and teams short of players', () {
      final stats = teamStats([
        _team(joined: 5, size: 5),
        _team(joined: 2, size: 4),
        _team(joined: 3, size: 4),
        _team(joined: 4, size: 4),
      ]);
      expect((stats.teams, stats.players, stats.incomplete), (4, 14, 2));
    });

    test('nothing registered is all zeros', () {
      final stats = teamStats(const []);
      expect((stats.teams, stats.players, stats.incomplete), (0, 0, 0));
    });

    test('a team without a size is never incomplete', () {
      expect(isIncomplete(_team(joined: 1, size: 0)), isFalse);
      expect(isIncomplete(_team(joined: 3, size: 4)), isTrue);
      expect(isIncomplete(_team(joined: 4, size: 4)), isFalse);
    });
  });

  group('matchesSearch', () {
    final team = _team(
      name: 'Bufnițele',
      members: [_m('u0', 'Ana Pop'), _m('u1', 'Mihai Ștefănescu')],
    );

    test('an empty or blank search matches every team', () {
      expect(matchesSearch(team, ''), isTrue);
      expect(matchesSearch(team, '   '), isTrue);
    });

    test('finds the team name, ignoring case and diacritics', () {
      expect(matchesSearch(team, 'bufnite'), isTrue);
      expect(matchesSearch(team, 'BUFNIȚ'), isTrue);
    });

    test('finds a member by name', () {
      expect(matchesSearch(team, 'stefanescu'), isTrue);
      expect(matchesSearch(team, ' ana '), isTrue);
    });

    test('finds the captain and the names typed on an old team', () {
      expect(matchesSearch(team, 'radu'), isTrue);
      expect(matchesSearch(_team(typed: 'Ion Popescu, Dan Pop'), 'popescu'), isTrue);
    });

    test('no match', () {
      expect(matchesSearch(team, 'lupii'), isFalse);
    });
  });

  group('teamSummaryLine', () {
    test('an incomplete team says so, open or not', () {
      final team = _team(joined: 2, size: 4);
      expect(teamSummary(team, expanded: false).text, '2 din 4 jucători · incompletă');
      expect(teamSummary(team, expanded: true).text, '2 din 4 jucători · incompletă');
      expect(teamSummary(team, expanded: false).warning, isTrue);
    });

    test('a full team names its captain while closed', () {
      final team = _team(joined: 4, size: 4, captainName: 'Radu Marin');
      final line = teamSummary(team, expanded: false);
      expect(line.text, '4 din 4 jucători · Căpitan: Radu M.');
      expect(line.warning, isFalse);
    });

    test('an open full team leaves the captain to the member list', () {
      expect(teamSummary(_team(joined: 5, size: 5), expanded: true).text, '5 din 5 jucători');
    });

    test('a full team without a captain name only counts', () {
      expect(teamSummary(_team(joined: 4, size: 4, captainName: ' '), expanded: false).text, '4 din 4 jucători');
    });

    test('a team without a size counts only who joined', () {
      expect(teamSummary(_team(joined: 1, size: 0, captainName: ''), expanded: false).text, '1 jucător');
      expect(teamSummary(_team(joined: 3, size: 0, captainName: ''), expanded: false).text, '3 jucători');
    });

    test('Romanian "de" from twenty up', () {
      expect(playersWord(1), '1 jucător');
      expect(playersWord(19), '19 jucători');
      expect(playersWord(20), '20 de jucători');
      expect(playersWord(101), '101 jucători');
    });
  });

  group('shortName', () {
    test('first name and the last name\'s initial', () {
      expect(shortName('Radu Marin'), 'Radu M.');
      expect(shortName('  Elena  Maria Dobre '), 'Elena D.');
      expect(shortName('Ștefan Țurcanu'), 'Ștefan Ț.');
    });

    test('one word or nothing stays as it is', () {
      expect(shortName('Radu'), 'Radu');
      expect(shortName('  '), '');
    });
  });

  group('members', () {
    test('the captain comes first, found by uid', () {
      final team = _team(
        captainUid: 'u2',
        captainName: 'Altcineva',
        members: [_m('u0', 'Mihai Ionescu'), _m('u1', 'Ioana Radu'), _m('u2', 'Ana Pop')],
      );
      final rows = orderedMembers(team);
      expect(rows.map((r) => r.member.displayName), ['Ana Pop', 'Mihai Ionescu', 'Ioana Radu']);
      expect(rows.map((r) => r.isCaptain), [true, false, false]);
    });

    test('without a captain uid the captain is found by name', () {
      final team = _team(typed: 'Ion Popescu, Radu Marin', captainName: 'radu marin');
      final rows = orderedMembers(team);
      expect(rows.first.member.displayName, 'Radu Marin');
      expect(rows.first.isCaptain, isTrue);
    });

    test('a captain uid nobody has marks no one', () {
      final team = _team(captainUid: 'zz', captainName: 'Ana Pop', members: [_m('u0', 'Ana Pop')]);
      expect(orderedMembers(team).single.isCaptain, isFalse);
    });

    test('initials: the stored ones, else from the name', () {
      expect(memberInitials(_m('u', 'Ana Pop', 'XY')), 'XY');
      expect(memberInitials(_m('u', 'Ana Pop')), 'AP');
      expect(memberInitials(_m('u', '')), '?');
    });

    test('the team initial', () {
      expect(teamInitial('vulpile'), 'V');
      expect(teamInitial('  ștrumfii'), 'Ș');
      expect(teamInitial(''), '?');
    });
  });

  group('contactLine', () {
    final four = [_m('a', 'A A'), _m('b', 'B B'), _m('c', 'C C'), _m('d', 'D D'), _m('e', 'E E')];

    test('the rest of the players, the phone and the email', () {
      expect(contactLine(_team(members: four)), '+ 2 jucători · 0722 123 456 · radu@email.ro');
      expect(contactLine(_team(members: four.take(4).toList())), '+ 1 jucător · 0722 123 456 · radu@email.ro');
    });

    test('leaves out what is missing', () {
      expect(contactLine(_team(members: four.take(3).toList(), phone: '')), 'radu@email.ro');
      expect(contactLine(_team(phone: ' ', email: '')), isNull);
    });
  });

  group('eventSubtitle', () {
    test('the event name and its short date', () {
      final event = Event(eventId: 'e', name: 'Moștenirea Cartografului', dateEvent: DateTime(2026, 11, 21, 10));
      expect(eventSubtitle(event), 'Moștenirea Cartografului · Sâm 21 nov');
    });

    test('whichever of the two exists', () {
      expect(eventSubtitle(Event(eventId: 'e', name: 'Joc')), 'Joc');
      expect(eventSubtitle(Event(eventId: 'e', dateEvent: DateTime(2026, 11, 22))), 'Dum 22 nov');
      expect(eventSubtitle(Event(eventId: 'e', name: ' ')), isNull);
    });
  });
}
