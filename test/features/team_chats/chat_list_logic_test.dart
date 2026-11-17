import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/team_chats/logic/chat_row.dart';
import 'package:teamxperience/features/team_chats/logic/chat_texts.dart';
import 'package:teamxperience/model/team.dart';

final _now = DateTime(2026, 11, 17, 12, 0);

Team _team(String name, {String? unread, DateTime? unreadAt, int? count, Map<String, Object>? photos}) => Team.fromMap({
      'name': name,
      if (unread != null)
        'unreadByAdmin': {
          'text': unread,
          if (unreadAt != null) 'at': Timestamp.fromDate(unreadAt),
          if (count != null) 'count': count,
        },
      if (photos != null) 'photoApprovals': photos,
    });

LastMessage _msg(int minutesAgo, {String text = 'Salut', bool organiser = false, bool photo = false}) => LastMessage(
      fromOrganiser: organiser,
      text: text,
      isPhoto: photo,
      at: _now.subtract(Duration(minutes: minutesAgo)),
    );

DateTime _ago(int minutes) => _now.subtract(Duration(minutes: minutes));

void main() {
  group('ChatRow', () {
    test('the badge is the unread messages plus the photos waiting', () {
      final row = ChatRow(
        team: _team('Vulpile', unread: 'Alo', count: 2, photos: {
          '2_0_0': {'status': 'pending', 'at': Timestamp.fromDate(_ago(3))},
          '1_0_0': {'status': 'approved'},
        }),
      );
      expect(row.badge, 3);
      expect(row.isUnread, isTrue);
    });

    test('nothing to read, nothing waiting: read', () {
      final row = ChatRow(team: _team('Bufnițele'), last: _msg(5));
      expect(row.badge, 0);
      expect(row.isUnread, isFalse);
    });

    test('the newest waiting photo gives the mission, counted from one', () {
      final row = ChatRow(
        team: _team('Vulpile', photos: {
          '0_0_0': {'status': 'pending', 'at': Timestamp.fromDate(_ago(30))},
          '2_1_0': {'status': 'pending', 'at': Timestamp.fromDate(_ago(4))},
        }),
      );
      expect(row.pendingPhotoMission, 3);
    });

    test('its time is the latest of the last message, the unread mark and a waiting photo', () {
      final row = ChatRow(
        team: _team('Vulpile', unread: 'Alo', unreadAt: _ago(9), photos: {
          '2_0_0': {'status': 'pending', 'at': Timestamp.fromDate(_ago(4))},
        }),
        last: _msg(20),
      );
      expect(row.time, _ago(4));
      expect(ChatRow(team: _team('Pisicile')).time, isNull);
    });
  });

  group('splitChatRows', () {
    test('unread first, newest first; then read by last message, newest first; no message last', () {
      final rows = [
        ChatRow(team: _team('Pisicile'), last: null),
        ChatRow(team: _team('Rapsodia'), last: _msg(105)),
        ChatRow(team: _team('Cometele', unread: 'Indiciu?', unreadAt: _ago(9)), last: _msg(9)),
        ChatRow(team: _team('Bufnițele'), last: _msg(78, organiser: true)),
        ChatRow(team: _team('Lupii', unread: 'Ușa?', unreadAt: _ago(1)), last: _msg(1)),
        ChatRow(team: _team('Albinele'), last: null),
      ];
      final split = splitChatRows(rows);
      expect(split.unread.map((r) => r.team.name), ['Lupii', 'Cometele']);
      expect(split.read.map((r) => r.team.name), ['Bufnițele', 'Rapsodia', 'Albinele', 'Pisicile']);
    });

    test('the same time: by team name', () {
      final split = splitChatRows([
        ChatRow(team: _team('Zebrele'), last: _msg(5)),
        ChatRow(team: _team('Albinele'), last: _msg(5)),
      ]);
      expect(split.read.map((r) => r.team.name), ['Albinele', 'Zebrele']);
    });
  });

  group('chatTime', () {
    test('minutes ago, then the time today', () {
      expect(chatTime(_now.subtract(const Duration(seconds: 20)), _now), 'acum');
      expect(chatTime(_ago(1), _now), 'acum 1 min');
      expect(chatTime(_ago(4), _now), 'acum 4 min');
      expect(chatTime(_ago(59), _now), 'acum 59 min');
      expect(chatTime(DateTime(2026, 11, 17, 10, 42), _now), '10:42');
      expect(chatTime(DateTime(2026, 11, 17, 0, 5), _now), '00:05');
    });

    test('yesterday, then a short date, with the year when it is another one', () {
      expect(chatTime(DateTime(2026, 11, 16, 23, 50), _now), 'ieri');
      expect(chatTime(DateTime(2026, 11, 14, 9), _now), '14 nov');
      expect(chatTime(DateTime(2025, 12, 30), _now), '30 dec 2025');
    });

    test('yesterday across a month', () {
      expect(chatTime(DateTime(2026, 10, 31, 22), DateTime(2026, 11, 1, 8)), 'ieri');
    });

    test('a clock a little ahead counts as now; no time is nothing', () {
      expect(chatTime(_now.add(const Duration(minutes: 2)), _now), 'acum');
      expect(chatTime(null, _now), '');
    });
  });

  group('chatPreview', () {
    test("the team's last message, or the organiser's with Tu:", () {
      expect(chatPreview(ChatRow(team: _team('A'), last: _msg(1, text: 'Ușa e închisă'))).text, 'Ușa e închisă');
      expect(
        chatPreview(ChatRow(team: _team('A'), last: _msg(1, text: 'Bravo!', organiser: true))).text,
        'Tu: Bravo!',
      );
    });

    test('a waiting photo comes before any message', () {
      final row = ChatRow(
        team: _team('A', photos: {'2_0_0': {'status': 'pending'}}),
        last: _msg(1, text: 'Fotografie încărcată pentru aprobare', photo: true),
      );
      final preview = chatPreview(row);
      expect(preview.text, 'Poză de aprobat · misiunea 3');
      expect(preview.photo, isTrue);
    });

    test('a picture without words says so', () {
      expect(chatPreview(ChatRow(team: _team('A'), last: _msg(1, text: '', photo: true))).text, 'Poză');
      expect(chatPreview(ChatRow(team: _team('A'), last: _msg(1, text: ' ', photo: true, organiser: true))).text, 'Tu: Poză');
    });

    test('no message yet; while loading, the unread mark or nothing', () {
      expect(chatPreview(ChatRow(team: _team('A'))).text, 'Niciun mesaj încă');
      expect(chatPreview(ChatRow(team: _team('A', unread: 'Alo'), lastLoaded: false)).text, 'Alo');
      expect(chatPreview(ChatRow(team: _team('A'), lastLoaded: false)).text, '');
    });

    test('long and multi-line text stays one line', () {
      expect(chatPreview(ChatRow(team: _team('A'), last: _msg(1, text: 'Unu\ndoi'))).text, 'Unu doi');
    });
  });

  group('header texts', () {
    test('the event and how many teams', () {
      expect(chatsHeaderLine('Moștenirea Cartografului', 12), 'Moștenirea Cartografului · 12 echipe');
      expect(chatsHeaderLine('Harta', 1), 'Harta · o echipă');
      expect(chatsHeaderLine('Harta', 20), 'Harta · 20 de echipe');
      expect(chatsHeaderLine(null, 3), '3 echipe');
      expect(chatsHeaderLine('  ', 0), '0 echipe');
    });

    test('the chips', () {
      expect(allChipLabel(12), 'Toate · 12');
      expect(unreadChipLabel(3), 'Necitite · 3');
    });
  });
}
