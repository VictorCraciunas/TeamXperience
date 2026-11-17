import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat/logic/chat_texts.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

Team _team({int progress = 0, bool started = true, bool finished = false}) => Team(
      name: 'Lupii de Cetate',
      teamMembers: '',
      captainName: 'Ana Pop',
      phoneNumber: '0722',
      captainEmail: '',
      captainUid: 'u1',
      missionProgress: progress,
      hasStarted: started,
      hasFinished: finished,
      members: const [
        TeamMember(uid: 'u1', displayName: 'Ana Pop', initials: 'AP'),
        TeamMember(uid: 'u2', displayName: 'Radu Ionescu', initials: 'RI'),
        TeamMember(uid: 'u3', displayName: 'Mihai', initials: ''),
      ],
    );

Message _from(String? uid, String? name) =>
    Message(sender: Role.USER, text: 'x', timestamp: DateTime(2026), senderUid: uid, senderName: name);

void main() {
  group('who wrote it', () {
    test('the organiser sees the captain marked; an unsigned message is the team\'s', () {
      final team = _team();
      expect(senderLabel(_from('u1', 'Ana'), team, organiserView: true), 'Ana · căpitan');
      expect(senderLabel(_from('u2', 'Radu'), team, organiserView: true), 'Radu');
      expect(senderLabel(_from(null, null), team, organiserView: true), 'Echipa');
    });

    test('a player sees teammates by first name and the organiser as "Organizator"', () {
      final team = _team();
      expect(senderLabel(_from('u1', 'Ana'), team, organiserView: false), 'Ana');
      final organiser = Message(sender: Role.ADMIN, text: 'x', timestamp: DateTime(2026));
      expect(senderLabel(organiser, team, organiserView: false), 'Organizator');
    });

    test('initials: the member\'s own, else from the name, else the team\'s', () {
      final team = _team();
      expect(senderInitials(_from('u1', 'Ana'), team), 'AP');
      expect(senderInitials(_from('u3', 'Mihai'), team), 'MI');
      expect(senderInitials(_from('u9', 'Ioana Dima'), team), 'ID');
      expect(senderInitials(_from(null, null), team), 'L');
    });
  });

  test('photo status pill', () {
    expect(photoStatusLabel(PhotoApprovalStatus.pending), 'De aprobat');
    expect(photoStatusLabel(PhotoApprovalStatus.approved), 'Aprobată');
    expect(photoStatusLabel(PhotoApprovalStatus.denied), 'Respinsă');
  });

  test('a photo key names its mission and puzzle, counted from one', () {
    expect(photoPlace('2_1_1731580000000'), (mission: 3, puzzle: 2));
    expect(photoPlace('2_1'), (mission: 3, puzzle: 2));
    expect(photoPlace('odd'), isNull);
    expect(photoPlace(null), isNull);
  });

  group('header', () {
    test('the members\' first names', () {
      expect(membersLine(_team()), 'Ana, Radu, Mihai');
      final old = Team(name: 'V', teamMembers: 'Ion Pop, Dan', captainName: '', phoneNumber: '', captainEmail: '');
      expect(membersLine(old), 'Ion, Dan');
    });

    test('the player\'s subtitle is the event and the team', () {
      expect(playerSubtitle('Moștenirea Cartografului', 'Lupii'), 'Moștenirea Cartografului · Lupii');
      expect(playerSubtitle(null, 'Lupii'), 'Lupii');
      expect(playerSubtitle('  ', 'Lupii'), 'Lupii');
    });

    test('the mission strip', () {
      expect(missionStrip(_team(progress: 3), 6), (text: 'Misiunea 4 din 6', done: 3, current: 3));
      expect(missionStrip(_team(started: false), 6), (text: 'N-au pornit încă', done: 0, current: null));
      expect(missionStrip(_team(progress: 6, finished: true), 6), (text: 'Au terminat · 6 din 6', done: 6, current: null));
      expect(missionStrip(_team(progress: 9), 6), (text: 'Au terminat · 6 din 6', done: 6, current: null));
      expect(missionStrip(_team(progress: 1), 0), isNull);
    });
  });
}
