import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/team.dart';

Team _team(Object? unread) => Team.fromMap({'name': 'Lupii', if (unread != null) 'unreadByAdmin': unread});

void main() {
  group('Team.unreadByAdmin', () {
    final at = DateTime(2026, 11, 8, 12);

    test('reads the text and the time', () {
      final team = _team({'text': 'Ușa e închisă', 'at': Timestamp.fromDate(at)});
      expect(team.unreadText, 'Ușa e închisă');
      expect(team.unreadAt, at);
    });

    test('nothing unread', () {
      final team = _team(null);
      expect(team.unreadText, isNull);
      expect(team.unreadAt, isNull);
    });

    test('a server time still on its way: the text, no time', () {
      final team = _team({'text': 'Alo', 'at': null});
      expect(team.unreadText, 'Alo');
      expect(team.unreadAt, isNull);
    });

    test('anything else counts as nothing', () {
      expect(_team(true).unreadText, isNull);
      expect(_team({'at': Timestamp.fromDate(at)}).unreadText, isNull);
    });

    test('toJson never writes it, so saving a team cannot clear or fake it', () {
      final team = _team({'text': 'Alo'});
      expect(team.toJson().containsKey('unreadByAdmin'), isFalse);
    });
  });

  group('Message.announcement', () {
    Message message({bool announcement = false}) =>
        Message(sender: Role.ADMIN, text: 'Pauză', timestamp: DateTime(2026), announcement: announcement);

    test('written only when true', () {
      expect(message().toJson().containsKey('announcement'), isFalse);
      expect(message(announcement: true).toJson()['announcement'], isTrue);
    });

    test('read back; old messages are not announcements', () {
      final stamp = Timestamp.fromDate(DateTime(2026));
      expect(Message.fromFirestore({'sender': 'ADMIN', 'timestamp': stamp, 'announcement': true}).announcement, isTrue);
      expect(Message.fromFirestore({'sender': 'ADMIN', 'timestamp': stamp}).announcement, isFalse);
    });
  });

  test('AdminEventStats counts the teams that have not started', () {
    Team team({bool started = false, bool finished = false}) =>
        Team(name: 'x', teamMembers: '', captainName: '', phoneNumber: '', captainEmail: '', hasStarted: started, hasFinished: finished);
    final stats = AdminEventStats.fromTeams([team(started: true), team(started: true, finished: true), team()]);
    expect(stats.inPlay, 1);
    expect(stats.finished, 1);
    expect(stats.notStarted, 1);
  });
}
