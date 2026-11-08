import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/live_room/logic/attention_queue.dart';
import 'package:teamxperience/features/live_room/logic/live_board.dart';
import 'package:teamxperience/features/live_room/logic/live_status.dart';
import 'package:teamxperience/features/live_room/logic/live_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/photo_detail.dart';
import 'package:teamxperience/model/team.dart';

final _now = DateTime(2026, 11, 14, 12);
DateTime _ago(int minutes) => _now.subtract(Duration(minutes: minutes));

Team _team(
  String name, {
  bool started = true,
  bool finished = false,
  int progress = 0,
  int puzzle = 0,
  DateTime? startedAt,
  Map<int, DateTime>? solved,
  Map<String, PhotoApprovalStatus>? photos,
  Map<String, PhotoDetail>? details,
  Map<String, int>? attempts,
  Map<String, DateTime>? presence,
  Map<String, DateTime>? locked,
  String? unread,
  DateTime? unreadAt,
}) =>
    Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      hasStarted: started,
      hasFinished: finished,
      missionProgress: progress,
      puzzleNumber: puzzle,
      startedAt: startedAt,
      missionCompletedAt: solved,
      photoApprovals: photos,
      photoDetails: details,
      attempts: attempts,
      presence: presence,
      lockedUntil: locked,
      unreadText: unread,
      unreadAt: unreadAt,
    );

LiveState _state(Team team, {bool over = false, int missions = 6}) =>
    liveStateOf(team, missionCount: missions, now: _now, eventOver: over);

List<AttentionItem> _queue(List<Team> teams, {bool over = false}) =>
    attentionQueue(teams, missionCount: 6, now: _now, eventOver: over);

List<BoardRow> _board(List<Team> teams, {BoardFilter filter = BoardFilter.all, int missions = 6}) =>
    boardRows(teams, missionCount: missions, now: _now, eventOver: false, filter: filter);

void main() {
  group('liveStateOf', () {
    test('not started', () => expect(_state(_team('A', started: false)), LiveState.notStarted));

    test('stuck from 20 minutes, not at 19', () {
      expect(_state(_team('A', solved: {0: _ago(19)})), LiveState.playing);
      expect(_state(_team('A', solved: {0: _ago(20)})), LiveState.stuck);
    });

    test('before the first mission the clock runs from the start', () {
      expect(_state(_team('A', startedAt: _ago(25))), LiveState.stuck);
      expect(_state(_team('A', startedAt: _ago(5))), LiveState.playing);
    });

    test('the latest mission counts, not the first', () {
      expect(_state(_team('A', startedAt: _ago(90), solved: {0: _ago(60), 1: _ago(3)})), LiveState.playing);
    });

    test('a photo waiting for the organiser is not being stuck', () {
      final team = _team('A', solved: {0: _ago(40)}, photos: {'1_0_0': PhotoApprovalStatus.pending});
      expect(_state(team), LiveState.waitingPhoto);
    });

    test('no start time on a started team: playing', () {
      expect(_state(_team('A')), LiveState.playing);
    });

    test('finished with every mission, stopped with fewer', () {
      expect(_state(_team('A', finished: true, progress: 6)), LiveState.finished);
      expect(_state(_team('A', finished: true, progress: 2)), LiveState.stopped);
    });

    test('progress past the end is finished, even before the flag lands', () {
      expect(_state(_team('A', progress: 9, solved: {5: _ago(50)})), LiveState.finished);
    });

    test('once the event is over, a team still out there has stopped', () {
      expect(_state(_team('A', solved: {0: _ago(90)}), over: true), LiveState.stopped);
      expect(_state(_team('A'), over: true), LiveState.stopped);
    });

    test('the end changes nothing for who finished, never started or waits on a photo', () {
      expect(_state(_team('A', progress: 6), over: true), LiveState.finished);
      expect(_state(_team('A', started: false), over: true), LiveState.notStarted);
      expect(_state(_team('A', photos: {'0_0_0': PhotoApprovalStatus.pending}), over: true), LiveState.waitingPhoto);
    });

    test('an event without missions does not count as finished', () {
      expect(_state(_team('A', finished: true), missions: 0), LiveState.stopped);
    });
  });

  group('liveCounts', () {
    final teams = [
      _team('Out there', progress: 1),
      _team('Done', finished: true, progress: 6),
      _team('Stopped', finished: true, progress: 2),
      _team('New', started: false),
    ];

    test('in play, finished and not started, by the same states as the board', () {
      final counts = liveCounts(teams, missionCount: 6, now: _now, eventOver: false);
      expect((counts.inPlay, counts.finished, counts.notStarted), (1, 1, 1));
    });

    test('after the end nobody is in play', () {
      final counts = liveCounts(teams, missionCount: 6, now: _now, eventOver: true);
      expect((counts.inPlay, counts.finished, counts.notStarted), (0, 1, 1));
    });

    test('stuck and waiting on a photo are in play', () {
      final counts = liveCounts([
        _team('A', solved: {0: _ago(40)}),
        _team('B', photos: {'0_0_0': PhotoApprovalStatus.pending}),
      ], missionCount: 6, now: _now, eventOver: false);
      expect(counts.inPlay, 2);
    });
  });

  group('eventEnded', () {
    test('stopped, or three hours after the start', () {
      expect(eventEnded(Event(eventId: 'e', isStopped: true), _now), isTrue);
      expect(eventEnded(Event(eventId: 'e', dateEvent: _now.subtract(const Duration(hours: 2))), _now), isFalse);
      expect(eventEnded(Event(eventId: 'e', dateEvent: _now.subtract(const Duration(hours: 3, seconds: 1))), _now), isTrue);
      expect(eventEnded(Event(eventId: 'e'), _now), isFalse);
    });
  });

  group('isSilent', () {
    test('no phone seen yet is not silent', () => expect(isSilent(_team('A'), _now), isFalse));

    test('more than five minutes, by the newest phone', () {
      expect(isSilent(_team('A', presence: {'u': _ago(4)}), _now), isFalse);
      expect(isSilent(_team('A', presence: {'u': _ago(6)}), _now), isTrue);
      expect(isSilent(_team('A', presence: {'u': _ago(30), 'v': _ago(1)}), _now), isFalse);
    });
  });

  group('attentionQueue', () {
    test('a pending photo with its picture and mission; decided ones are gone', () {
      final team = _team(
        'Vulpile',
        photos: {
          '2_0_1': PhotoApprovalStatus.pending,
          '2_0_0': PhotoApprovalStatus.denied,
          '1_0_0': PhotoApprovalStatus.approved,
        },
        details: {'2_0_1': PhotoDetail(status: PhotoApprovalStatus.pending, url: 'u', at: _ago(1))},
      );
      final items = _queue([team]);
      expect(items, hasLength(1));
      final photo = items.single as PhotoAttention;
      expect((photo.key, photo.url, photo.mission), ('2_0_1', 'u', 3));
    });

    test('stuck and wrong attempts on one card', () {
      final team = _team('Cometele', progress: 1, solved: {0: _ago(25)}, attempts: {'1_0': 3});
      final item = _queue([team]).single as StuckAttention;
      expect((item.minutes, item.wrong, item.mission), (25, 3, 2));
    });

    test('three wrong and not stuck still shows, with no minutes', () {
      final item = _queue([_team('A', progress: 1, solved: {0: _ago(2)}, attempts: {'1_0': 3})]).single as StuckAttention;
      expect(item.minutes, isNull);
      expect(item.wrong, 3);
    });

    test('two wrong and not stuck is nothing', () {
      expect(_queue([_team('A', progress: 1, solved: {0: _ago(2)}, attempts: {'1_0': 2})]), isEmpty);
    });

    test('wrong answers on another puzzle do not count', () {
      expect(_queue([_team('A', progress: 1, puzzle: 1, solved: {0: _ago(2)}, attempts: {'1_0': 5})]), isEmpty);
    });

    test('a puzzle locked for running out of attempts shows while it is locked, on top', () {
      final until = _now.add(const Duration(seconds: 40));
      final items = _queue([
        _team('Lupii', progress: 1, solved: {0: _ago(2)}, locked: {'1_0': until}),
        _team('Other', unread: 'x', unreadAt: _ago(1)),
      ]);
      final item = items.first as StuckAttention;
      expect((item.team.name, item.locked, item.minutes, item.wrong), ('Lupii', true, null, 0));
      expect(item.at, until);
    });

    test('a lock that ended, or on another puzzle, is nothing', () {
      expect(_queue([_team('A', progress: 1, solved: {0: _ago(2)}, locked: {'1_0': _ago(1)})]), isEmpty);
      expect(_queue([_team('A', progress: 1, solved: {0: _ago(2)}, locked: {'0_0': _now.add(const Duration(minutes: 1))})]), isEmpty);
    });

    test('an unread message, also from a team that finished', () {
      final item = _queue([_team('Lupii', finished: true, progress: 6, unread: 'Alo', unreadAt: _ago(1))]).single;
      expect((item as MessageAttention).text, 'Alo');
    });

    test('after the end: no stuck or wrong, photos and messages stay', () {
      final teams = [
        _team('A', progress: 1, solved: {0: _ago(90)}, attempts: {'1_0': 3}),
        _team('B', photos: {'0_0_0': PhotoApprovalStatus.pending}),
        _team('C', unread: 'Alo'),
      ];
      final items = _queue(teams, over: true);
      expect(items.map((i) => i.team.name), unorderedEquals(['B', 'C']));
    });

    test('a team that has not started gives nothing', () {
      expect(_queue([_team('A', started: false)]), isEmpty);
    });

    test('newest first, ties by name, a pending server time on top', () {
      final items = _queue([
        _team('Old', unread: 'x', unreadAt: _ago(30)),
        _team('Mid2', unread: 'x', unreadAt: _ago(5)),
        _team('Mid1', unread: 'x', unreadAt: _ago(5)),
        _team('Pending', unread: 'x'),
      ]);
      expect(items.map((i) => i.team.name), ['Pending', 'Mid1', 'Mid2', 'Old']);
    });

    test('a team can have a photo, and a message, on separate cards', () {
      final items = _queue([_team('A', photos: {'0_0_0': PhotoApprovalStatus.pending}, unread: 'x')]);
      expect(items, hasLength(2));
    });
  });

  group('boardRows', () {
    test('places for started teams; those not started last, without a place, by name', () {
      final rows = _board([
        _team('Zebra', started: false),
        _team('Lupii', progress: 1, solved: {0: _ago(1)}),
        _team('Albine', started: false),
        _team('Bufnitele', progress: 5, solved: {4: _ago(2)}),
      ]);
      expect(rows.map((r) => (r.team.name, r.place)), [
        ('Bufnitele', 1),
        ('Lupii', 2),
        ('Albine', null),
        ('Zebra', null),
      ]);
    });

    test('done never passes the mission count', () {
      expect(_board([_team('A', progress: 9)]).single.done, 6);
    });

    test('since is the latest mission, or the start', () {
      expect(_board([_team('A', startedAt: _ago(9), solved: {0: _ago(2)})]).single.since, _ago(2));
      expect(_board([_team('A', startedAt: _ago(9))]).single.since, _ago(9));
    });

    test('the filters', () {
      final teams = [_team('Stuck', solved: {0: _ago(30)}), _team('Fine', solved: {0: _ago(1)}), _team('New', started: false)];
      expect(_board(teams, filter: BoardFilter.stuck).map((r) => r.team.name), ['Stuck']);
      expect(_board(teams, filter: BoardFilter.notStarted).map((r) => r.team.name), ['New']);
      expect(_board(teams), hasLength(3));
    });

    test('no teams, no missions: no trouble', () {
      expect(_board(const []), isEmpty);
      expect(_board([_team('A')], missions: 0).single.done, 0);
    });
  });

  group('texts', () {
    test('the header line', () {
      Event starts(Duration d) => Event(eventId: 'e', dateEvent: _now.add(d));
      expect(liveHeaderLine(starts(const Duration(hours: 2, minutes: 10)), _now), 'Începe în 2 h 10 min');
      expect(liveHeaderLine(starts(const Duration(minutes: 10)), _now), 'Începe în 10 min');
      expect(liveHeaderLine(starts(const Duration(days: 3)), _now), 'Începe în 3 zile');
      expect(liveHeaderLine(starts(const Duration(seconds: 20)), _now), 'Începe acum');
      expect(liveHeaderLine(starts(const Duration(hours: -1, minutes: -42, seconds: -18)), _now), '1:17:42 rămase');
      expect(liveHeaderLine(Event(eventId: 'e', dateEvent: _now, isStopped: true), _now), 'Oprit');
      expect(liveHeaderLine(starts(const Duration(hours: -4)), _now), 'Încheiat');
      expect(liveHeaderLine(Event(eventId: 'e'), _now), '');
    });

    test('isLive: started and not ended', () {
      expect(isLive(Event(eventId: 'e', dateEvent: _ago(10)), _now), isTrue);
      expect(isLive(Event(eventId: 'e', dateEvent: _now.add(const Duration(minutes: 1))), _now), isFalse);
      expect(isLive(Event(eventId: 'e', dateEvent: _ago(10), isStopped: true), _now), isFalse);
    });

    test('the board header', () {
      expect(boardHeaderLine(12, 6), '12 echipe · 6 misiuni');
      expect(boardHeaderLine(1, 1), 'O echipă · O misiune');
      expect(boardHeaderLine(0, 0), '0 echipe · 0 misiuni');
      expect(boardHeaderLine(20, 3), '20 de echipe · 3 misiuni');
    });

    test('the board status', () {
      String text(Team t) => boardStatusText(_board([t]).single, _now);
      expect(text(_team('A', solved: {0: _ago(2)})), 'acum 2 min');
      expect(text(_team('A', solved: {0: _now})), 'acum');
      expect(text(_team('A')), 'în joc');
      expect(text(_team('A', photos: {'0_0_0': PhotoApprovalStatus.pending})), 'poză în așteptare');
      expect(text(_team('A', solved: {0: _ago(25)})), 'blocați 25 min');
      expect(text(_team('A', solved: {0: _ago(65)})), 'blocați 1 h 5 min');
      expect(text(_team('A', started: false)), 'n-au introdus codul');
      expect(text(_team('A', finished: true, progress: 6)), 'au terminat');
      expect(text(_team('A', finished: true, progress: 2)), 'oprită');
    });

    test('the stuck card', () {
      final both = _queue([_team('Cometele', progress: 1, solved: {0: _ago(25)}, attempts: {'1_0': 3})]).single as StuckAttention;
      expect(stuckTitle(both), 'Cometele stau de 25 min');
      expect(stuckSubtitle(both), 'Misiunea 2 · 3 încercări greșite');

      final time = _queue([_team('Lupii', progress: 1, solved: {0: _ago(21)})]).single as StuckAttention;
      expect(stuckSubtitle(time), 'Misiunea 2');

      final one = _queue([_team('Lupii', progress: 1, solved: {0: _ago(21)}, attempts: {'1_0': 1})]).single as StuckAttention;
      expect(stuckSubtitle(one), 'Misiunea 2 · o încercare greșită');

      final wrong = _queue([_team('Lupii', progress: 1, solved: {0: _ago(2)}, attempts: {'1_0': 4})]).single as StuckAttention;
      expect(stuckTitle(wrong), 'Lupii: 4 încercări greșite');
      expect(stuckSubtitle(wrong), 'Misiunea 2');

      final until = {'1_0': _now.add(const Duration(minutes: 1))};
      final locked = _queue([_team('Lupii', progress: 1, solved: {0: _ago(2)}, locked: until)]).single as StuckAttention;
      expect(stuckTitle(locked), 'Lupii: încercări epuizate');
      expect(stuckSubtitle(locked), 'Misiunea 2');

      final stuckLocked = _queue([_team('Lupii', progress: 1, solved: {0: _ago(30)}, locked: until)]).single as StuckAttention;
      expect(stuckTitle(stuckLocked), 'Lupii stau de 30 min');
      expect(stuckSubtitle(stuckLocked), 'Misiunea 2 · încercări epuizate');
    });

    test('the initial on a pin', () {
      expect(teamInitial(''), '?');
      expect(teamInitial('  '), '?');
      expect(teamInitial('vulpile'), 'V');
      expect(teamInitial('🦊 Vulpile'), '🦊');
    });
  });
}
