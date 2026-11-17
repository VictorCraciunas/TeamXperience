import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/team_chats/logic/chat_row.dart';
import 'package:teamxperience/features/team_chats/logic/organiser_unread.dart';
import 'package:teamxperience/model/team.dart';

Team _team({String? unread, int? count, Map<String, Object>? photos}) => Team.fromMap({
      'name': 'Vulpile',
      if (unread != null) 'unreadByAdmin': {'text': unread, if (count != null) 'count': count},
      if (photos != null) 'photoApprovals': photos,
    });

void main() {
  group('organiserUnread', () {
    test('unread messages plus photos waiting for a decision', () {
      final team = _team(unread: 'Alo', count: 2, photos: {
        '2_0_0': {'status': 'pending', 'at': Timestamp.fromDate(DateTime(2026, 11, 17, 10))},
        '1_0_0': {'status': 'approved'},
        '0_0_0': {'status': 'denied'},
      });
      expect(organiserUnread(team), 3);
      expect(needsOrganiser(team), isTrue);
    });

    test('only a photo waiting still needs the organiser', () {
      final team = _team(photos: {'0_1_0': 'pending'});
      expect(organiserUnread(team), 1);
      expect(needsOrganiser(team), isTrue);
    });

    test('nothing unread and no photo waiting: nothing to do', () {
      final team = _team(photos: {'0_1_0': 'approved'});
      expect(organiserUnread(team), 0);
      expect(needsOrganiser(team), isFalse);
    });

    test('an unread text counts once even without a count, a count without text not at all', () {
      final built = Team(
        name: 'Vulpile',
        teamMembers: '',
        captainName: '',
        phoneNumber: '',
        captainEmail: '',
        unreadText: 'Alo',
      );
      expect(organiserUnread(built), 1);
      final stale = Team(
        name: 'Vulpile',
        teamMembers: '',
        captainName: '',
        phoneNumber: '',
        captainEmail: '',
        unreadCount: 2,
      );
      expect(organiserUnread(stale), 0);
      expect(needsOrganiser(stale), isFalse);
    });

    test('the conversations list reads the same', () {
      for (final team in [
        _team(unread: 'Alo', count: 2, photos: {'2_0_0': 'pending'}),
        _team(photos: {'0_1_0': 'pending'}),
        _team(),
      ]) {
        final row = ChatRow(team: team);
        expect(row.badge, organiserUnread(team));
        expect(row.isUnread, needsOrganiser(team));
      }
    });
  });
}
