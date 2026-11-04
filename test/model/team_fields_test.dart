import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

void main() {
  final oldMap = <String, dynamic>{
    'name': 'Vulpile',
    'teamMembers': 'Ana Pop, Ion',
    'captainName': 'Ana',
    'phoneNumber': '0700',
    'captainEmail': 'a@b.ro',
    'latitude': 0.0,
    'longitude': 0.0,
  };

  test('an old team document reads as the defaults', () {
    final team = Team.fromMap(oldMap);
    expect(team.crewId, isNull);
    expect(team.captainUid, isNull);
    expect(team.members, isEmpty);
    expect(team.inviteCode, isNull);
    expect(team.photoConsent, isFalse);
    expect(team.displayCode, isNull);
  });

  test('old documents without coordinates still read', () {
    final team = Team.fromMap({'name': 'X'});
    expect(team.latitude, 0);
    expect(team.longitude, 0);
  });

  test('memberList for an old team comes from teamMembers', () {
    final list = Team.fromMap(oldMap).memberList;
    expect(list.map((m) => m.displayName), ['Ana Pop', 'Ion']);
    expect(list.map((m) => m.initials), ['AP', 'I']);
    expect(list.map((m) => m.uid), ['', '']);
  });

  test('memberList trims names and skips empty pieces', () {
    final team = Team.fromMap({...oldMap, 'teamMembers': ' ana  pop , ,ion,'});
    expect(team.memberList.map((m) => m.displayName), ['ana  pop', 'ion']);
    expect(team.memberList.map((m) => m.initials), ['AP', 'I']);
  });

  test('memberList is empty when there are no names', () {
    expect(Team.fromMap({...oldMap, 'teamMembers': ''}).memberList, isEmpty);
  });

  test('a team with members uses them in memberList', () {
    final team = Team.fromMap({
      ...oldMap,
      'members': [
        {'uid': 'u1', 'displayName': 'Maria Ene', 'initials': 'ME'},
      ],
    });
    expect(team.memberList.length, 1);
    expect(team.memberList.first.uid, 'u1');
  });

  test('the new fields round-trip', () {
    final team = Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Ana',
      phoneNumber: '',
      captainEmail: '',
      crewId: 'c1',
      captainUid: 'u1',
      members: const [
        TeamMember(uid: 'u1', displayName: 'Ana Pop', initials: 'AP'),
      ],
      inviteCode: 'VLP482',
      photoConsent: true,
    );
    final back = Team.fromMap(team.toJson());
    expect(back.crewId, 'c1');
    expect(back.captainUid, 'u1');
    expect(back.members.single.displayName, 'Ana Pop');
    expect(back.inviteCode, 'VLP482');
    expect(back.displayCode, 'VLP-482');
    expect(back.photoConsent, isTrue);
  });
}
