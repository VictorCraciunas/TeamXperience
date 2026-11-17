import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat/logic/chat_timeline.dart';
import 'package:teamxperience/features/chat/logic/bubble_position.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/photo_detail.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

final _now = DateTime(2026, 11, 14, 12);
DateTime _at(int h, int m, {int day = 14}) => DateTime(2026, 11, day, h, m);

Team _team({
  Map<int, DateTime>? solved,
  Map<String, PhotoApprovalStatus>? approvals,
  Map<String, PhotoDetail>? details,
}) =>
    Team(
      name: 'Lupii',
      teamMembers: '',
      captainName: 'Ana',
      phoneNumber: '',
      captainEmail: '',
      captainUid: 'u1',
      members: const [TeamMember(uid: 'u1', displayName: 'Ana Pop', initials: 'AP')],
      missionCompletedAt: solved,
      photoApprovals: approvals,
      photoDetails: details,
    );

ChatMessageDoc _player(String id, DateTime at, {String? uid = 'u1', String? name = 'Ana', String text = 'Hei'}) =>
    ChatMessageDoc(id, Message(sender: Role.USER, text: text, timestamp: at, senderUid: uid, senderName: name));

ChatMessageDoc _organiser(String id, DateTime at, {bool announcement = false}) =>
    ChatMessageDoc(id, Message(sender: Role.ADMIN, text: 'Da', timestamp: at, announcement: announcement));

ChatMessageDoc _photo(String id, DateTime at, {String? key, String? uid = 'u2', String? name = 'Mihai'}) => ChatMessageDoc(
      id,
      Message(
        sender: Role.USER,
        text: 'Fotografie',
        timestamp: at,
        type: MessageType.image,
        imageUrl: 'https://x/$id.jpg',
        approvalKey: key,
        senderUid: uid,
        senderName: name,
      ),
    );

List<ChatEntry> _organiserView(List<ChatMessageDoc> messages, Team team) =>
    chatTimeline(messages: messages, team: team, organiserView: true, myUid: 'admin', now: _now);

List<ChatEntry> _playerView(List<ChatMessageDoc> messages, Team team, {String me = 'u1'}) =>
    chatTimeline(messages: messages, team: team, organiserView: false, myUid: me, now: _now);

void main() {
  test('solved missions sit between the messages by time, under one day line', () {
    final team = _team(solved: {2: _at(10, 40)});
    final entries = _organiserView([_player('a', _at(10, 30)), _organiser('b', _at(10, 48))], team);
    expect(entries.map((e) => e.runtimeType), [ChatDayEntry, ChatTextEntry, ChatGameEventEntry, ChatTextEntry]);
    expect((entries[0] as ChatDayEntry).label, 'Astăzi');
    expect((entries[2] as ChatGameEventEntry).text, 'Au rezolvat misiunea 3 · 10:40');
    expect((_playerView([], team).last as ChatGameEventEntry).text, 'Ați rezolvat misiunea 3 · 10:40');
  });

  test('a new day gets its own line', () {
    final entries = _organiserView([_player('a', _at(9, 0, day: 13)), _player('b', _at(9, 0))], _team());
    final days = entries.whereType<ChatDayEntry>().map((e) => e.label);
    expect(days, ['Ieri', 'Astăzi']);
  });

  group('organiser view', () {
    test('team messages on the left with name and initials; own ones on the right', () {
      final entries = _organiserView([_player('a', _at(10, 30)), _organiser('b', _at(10, 48))], _team());
      final team = entries[1] as ChatTextEntry;
      expect(team.mine, isFalse);
      expect(team.name, 'Ana · căpitan');
      expect(team.avatar, const ChatAvatar.initials('AP'));
      expect(team.footer, '10:30');
      final own = entries[2] as ChatTextEntry;
      expect(own.mine, isTrue);
      expect(own.name, isNull);
      expect(own.avatar, isNull);
      expect(own.footer, '10:48');
    });

    test('a run from one sender: name on the first, avatar and time on the last', () {
      final entries = _organiserView([
        _player('a', _at(10, 30)),
        _player('b', _at(10, 31)),
        _player('c', _at(10, 32)),
        _player('d', _at(10, 33), uid: 'u2', name: 'Radu'),
      ], _team()).whereType<ChatTextEntry>().toList();
      expect(entries.map((e) => e.position),
          [BubblePosition.first, BubblePosition.middle, BubblePosition.last, BubblePosition.single]);
      expect(entries.map((e) => e.name), ['Ana · căpitan', null, null, 'Radu']);
      expect(entries.map((e) => e.avatar != null), [false, false, true, true]);
      expect(entries.map((e) => e.footer), [null, null, '10:32', '10:33']);
    });

    test('a solved mission breaks a run', () {
      final entries = _organiserView(
        [_player('a', _at(10, 30)), _player('b', _at(10, 50))],
        _team(solved: {0: _at(10, 40)}),
      ).whereType<ChatTextEntry>();
      expect(entries.map((e) => e.position), [BubblePosition.single, BubblePosition.single]);
    });

    test('a puzzle photo is a card to decide while it waits', () {
      final team = _team(approvals: {'2_1_5': PhotoApprovalStatus.pending});
      final card = _organiserView([_photo('p', _at(10, 52), key: '2_1_5')], team).last as ChatPhotoReviewEntry;
      expect(card.title, 'Mihai a trimis poza');
      expect(card.line, 'Misiunea 3 · Puzzle 2 · 10:52');
      expect(card.statusLabel, 'De aprobat');
      expect(card.canDecide, isTrue);
      expect(card.approvalKey, '2_1_5');
      expect(card.initials, 'MI');
    });

    test('a decided photo keeps its card, without the buttons, with the reason', () {
      final team = _team(
        approvals: {'2_1_5': PhotoApprovalStatus.denied},
        details: {'2_1_5': const PhotoDetail(status: PhotoApprovalStatus.denied, reason: 'Nu se vede ceasul')},
      );
      final card = _organiserView([_photo('p', _at(10, 52), key: '2_1_5', uid: null, name: null)], team).last
          as ChatPhotoReviewEntry;
      expect(card.title, 'Echipa a trimis poza');
      expect(card.statusLabel, 'Respinsă');
      expect(card.canDecide, isFalse);
      expect(card.reason, 'Nu se vede ceasul');
    });

    test('a chat photo (no key) is a plain picture', () {
      final entry = _organiserView([_photo('p', _at(10, 52))], _team()).last as ChatPhotoEntry;
      expect(entry.mine, isFalse);
      expect(entry.statusLabel, isNull);
      expect(entry.line, '10:52');
      expect(entry.name, 'Mihai');
    });
  });

  group('player view', () {
    test('mine on the right as "Tu"; the organiser and teammates on the left', () {
      final entries = _playerView([
        _player('a', _at(10, 46)),
        _organiser('b', _at(10, 48)),
        _player('c', _at(10, 56), uid: 'u2', name: 'Mihai'),
        _player('d', _at(10, 57), uid: null, name: null),
      ], _team()).whereType<ChatTextEntry>().toList();
      expect(entries[0].mine, isTrue);
      expect(entries[0].footer, 'Tu · 10:46');
      expect(entries[0].name, isNull);
      expect(entries[1].mine, isFalse);
      expect(entries[1].name, 'Organizator');
      expect(entries[1].avatar, const ChatAvatar.organiser());
      expect(entries[2].name, 'Mihai');
      expect(entries[2].avatar, const ChatAvatar.initials('MI'));
      // An unsigned old message cannot be told apart: it is the team's.
      expect(entries[3].mine, isFalse);
      expect(entries[3].name, 'Echipa');
    });

    test('announcements are their own card', () {
      final entry = _playerView([_organiser('a', _at(10, 30), announcement: true)], _team()).last
          as ChatAnnouncementEntry;
      expect(entry.title, 'Anunț pentru toate echipele · 10:30');
      expect(entry.text, 'Da');
    });

    test('a puzzle photo shows its status and mission', () {
      final team = _team(approvals: {'2_0_1': PhotoApprovalStatus.approved});
      final entry = _playerView([_photo('p', _at(10, 53), key: '2_0_1', uid: 'u1')], team).last as ChatPhotoEntry;
      expect(entry.mine, isTrue);
      expect(entry.status, PhotoApprovalStatus.approved);
      expect(entry.statusLabel, 'Aprobată');
      expect(entry.line, 'Misiunea 3 · 10:53');
      expect(entry.name, isNull);
    });

    test('a rejected photo carries the organiser\'s reason', () {
      final team = _team(
        approvals: {'2_0_1': PhotoApprovalStatus.denied},
        details: {'2_0_1': const PhotoDetail(status: PhotoApprovalStatus.denied, reason: ' Nu se vede ')},
      );
      final entry = _playerView([_photo('p', _at(10, 53), key: '2_0_1', uid: 'u1')], team).last as ChatPhotoEntry;
      expect(entry.reason, 'Nu se vede');
    });
  });
}
