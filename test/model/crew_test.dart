import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/model/team_member.dart';

void main() {
  final map = <String, dynamic>{
    'name': 'Vulpile',
    'captainUid': 'u2',
    'memberUids': ['u1', 'u2'],
    'members': [
      {'uid': 'u1', 'displayName': 'Ana Pop', 'initials': 'AP'},
      {'uid': 'u2', 'displayName': 'Ion', 'initials': 'I'},
    ],
    'inviteCode': 'VLP482',
  };

  test('fromMap reads every field', () {
    final crew = Crew.fromMap('c1', map);
    expect(crew.id, 'c1');
    expect(crew.name, 'Vulpile');
    expect(crew.captainUid, 'u2');
    expect(crew.memberUids, ['u1', 'u2']);
    expect(crew.members.length, 2);
    expect(crew.members.first.displayName, 'Ana Pop');
    expect(crew.inviteCode, 'VLP482');
  });

  test('displayCode shows the dash', () {
    expect(Crew.fromMap('c1', map).displayCode, 'VLP-482');
  });

  test('captain is the member whose uid is captainUid', () {
    final captain = Crew.fromMap('c1', map).captain;
    expect(captain?.uid, 'u2');
    expect(captain?.initials, 'I');
  });

  test('captain is null when no member matches', () {
    final crew = Crew.fromMap('c1', {...map, 'captainUid': 'nobody'});
    expect(crew.captain, isNull);
  });

  test('an empty map reads as empty values', () {
    final crew = Crew.fromMap('c1', {});
    expect(crew.name, '');
    expect(crew.memberUids, isEmpty);
    expect(crew.members, isEmpty);
    expect(crew.captain, isNull);
  });

  test('TeamMember round-trips', () {
    const member = TeamMember(uid: 'u1', displayName: 'Ana Pop', initials: 'AP');
    final back = TeamMember.fromMap(member.toJson());
    expect(back.uid, 'u1');
    expect(back.displayName, 'Ana Pop');
    expect(back.initials, 'AP');
  });
}
