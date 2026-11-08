import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/live_room/controller/live_room_controller.dart';
import 'package:teamxperience/features/live_room/logic/attention_queue.dart';
import 'package:teamxperience/features/live_room/logic/live_board.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

final _now = DateTime(2026, 11, 14, 12);

Team _team(String name, {String phone = '', bool started = false}) =>
    Team(name: name, teamMembers: '', captainName: '', phoneNumber: phone, captainEmail: '', hasStarted: started);

class _Room {
  _Room({DateTime? start, bool stopped = false}) {
    controller = LiveRoomController(
      event: Event(eventId: 'e', name: 'Harta', dateEvent: start ?? _now.subtract(const Duration(hours: 1)), isStopped: stopped),
      eventStream: events.stream,
      teamStream: teams.stream,
      writeApproval: (team, key, status, {reason, url}) async {
        approvals.add((team.name, key, status, reason, url));
        final gate = approvalGate;
        if (gate != null) await gate.future;
        if (approvalFails) throw Exception('no');
      },
      stopEvent: (id) async {
        stops.add(id);
        if (stopFails) throw Exception('no');
      },
      postToChats: (names, text) async {
        if (postFails) throw Exception('no');
        posts.add((names, text));
      },
      pushNotification: (title, text) async {
        pushes.add((title, text));
        return pushWorks;
      },
      openPhone: (uri) async {
        calls.add(uri);
        return phoneOpens;
      },
      now: () => _now,
    );
  }

  final events = StreamController<Event>();
  final teams = StreamController<List<Team>>();
  late final LiveRoomController controller;

  final approvals = <(String, String, PhotoApprovalStatus, String?, String?)>[];
  final stops = <String>[];
  final posts = <(List<String>, String)>[];
  final pushes = <(String, String)>[];
  final calls = <Uri>[];
  Completer<void>? approvalGate;
  bool approvalFails = false;
  bool stopFails = false;
  bool postFails = false;
  bool pushWorks = true;
  bool phoneOpens = true;

  Future<void> give(List<Team> list) async {
    teams.add(list);
    await Future<void>.delayed(Duration.zero);
  }
}

PhotoAttention _photo(Team team) => PhotoAttention(team: team, at: _now, key: '1_0_0', url: 'u', mission: 2);

void main() {
  test('teams arrive and notify; it stops loading', () async {
    final room = _Room();
    var notified = 0;
    room.controller.addListener(() => notified++);
    expect(room.controller.loading, isTrue);
    await room.give([_team('A', started: true), _team('B')]);
    expect(room.controller.loading, isFalse);
    expect(room.controller.teams, hasLength(2));
    expect(room.controller.stats.inPlay, 1);
    expect(room.controller.stats.notStarted, 1);
    expect(notified, 1);
  });

  test('a stream error is kept, and the last teams stay', () async {
    final room = _Room();
    await room.give([_team('A')]);
    room.teams.addError(Exception('refused'));
    await Future<void>.delayed(Duration.zero);
    expect(room.controller.error, isNotNull);
    expect(room.controller.teams, hasLength(1));
  });

  group('stop', () {
    test('only after the start and before the end', () {
      expect(_Room().controller.canStop, isTrue);
      expect(_Room(start: _now.add(const Duration(hours: 1))).controller.canStop, isFalse);
      expect(_Room(stopped: true).controller.canStop, isFalse);
      expect(_Room(start: _now.subtract(const Duration(hours: 4))).controller.canStop, isFalse);
    });

    test('another organiser stopping it reaches this room', () async {
      final room = _Room();
      room.events.add(Event(eventId: 'e', dateEvent: _now.subtract(const Duration(hours: 1)), isStopped: true));
      await Future<void>.delayed(Duration.zero);
      expect(room.controller.canStop, isFalse);
      expect(room.controller.ended, isTrue);
    });

    test('stops once, and can no longer stop', () async {
      final room = _Room();
      expect(await room.controller.stop(), isTrue);
      expect(room.stops, ['e']);
      expect(room.controller.canStop, isFalse);
    });

    test('a failure says so and leaves it running', () async {
      final room = _Room()..stopFails = true;
      expect(await room.controller.stop(), isFalse);
      expect(room.controller.canStop, isTrue);
    });
  });

  group('decidePhoto', () {
    test('approve keeps the picture and gives no reason', () async {
      final room = _Room();
      expect(await room.controller.decidePhoto(_photo(_team('A')), approve: true), isTrue);
      expect(room.approvals.single, ('A', '1_0_0', PhotoApprovalStatus.approved, null, 'u'));
    });

    test('reject passes the reason', () async {
      final room = _Room();
      await room.controller.decidePhoto(_photo(_team('A')), approve: false, reason: 'Nu se vede');
      expect(room.approvals.single, ('A', '1_0_0', PhotoApprovalStatus.denied, 'Nu se vede', 'u'));
    });

    test('a second tap while the first is on its way writes nothing', () async {
      final room = _Room()..approvalGate = Completer<void>();
      final item = _photo(_team('A'));
      final first = room.controller.decidePhoto(item, approve: true);
      expect(room.controller.isDeciding(item), isTrue);
      expect(await room.controller.decidePhoto(item, approve: true), isFalse);
      room.approvalGate?.complete();
      expect(await first, isTrue);
      expect(room.approvals, hasLength(1));
      expect(room.controller.isDeciding(item), isFalse);
    });

    test('a failed write says so and can be tried again', () async {
      final room = _Room()..approvalFails = true;
      final item = _photo(_team('A'));
      expect(await room.controller.decidePhoto(item, approve: true), isFalse);
      room.approvalFails = false;
      expect(await room.controller.decidePhoto(item, approve: true), isTrue);
    });
  });

  group('announce', () {
    test('every team chat, then the push with the event name', () async {
      final room = _Room();
      await room.give([_team('A'), _team('B')]);
      expect(await room.controller.announce('  Pauză  '), AnnounceResult.sent);
      expect(room.posts.single.$1, ['A', 'B']);
      expect(room.posts.single.$2, 'Pauză');
      expect(room.pushes.single, ('Harta', 'Pauză'));
    });

    test('the push fails: the chats have it', () async {
      final room = _Room()..pushWorks = false;
      await room.give([_team('A')]);
      expect(await room.controller.announce('Pauză'), AnnounceResult.chatsOnly);
    });

    test('the chats fail: no push', () async {
      final room = _Room()..postFails = true;
      await room.give([_team('A')]);
      expect(await room.controller.announce('Pauză'), AnnounceResult.failed);
      expect(room.pushes, isEmpty);
    });

    test('blank text does nothing', () async {
      final room = _Room();
      await room.give([_team('A')]);
      expect(await room.controller.announce('   '), AnnounceResult.nothing);
      expect(room.posts, isEmpty);
      expect(room.pushes, isEmpty);
    });

    test('before the teams arrive it cannot reach their chats', () async {
      final room = _Room();
      expect(await room.controller.announce('Pauză'), AnnounceResult.failed);
      expect(room.pushes, isEmpty);
    });

    test('no teams at all: just the push', () async {
      final room = _Room();
      await room.give([]);
      expect(await room.controller.announce('Pauză'), AnnounceResult.sent);
      expect(room.posts, isEmpty);
      expect(room.pushes, hasLength(1));
    });
  });

  group('calling the captain', () {
    test('phoneUri keeps digits and plus', () {
      expect(phoneUri('0722 123-456'), Uri(scheme: 'tel', path: '0722123456'));
      expect(phoneUri('+40 722'), Uri(scheme: 'tel', path: '+40722'));
      expect(phoneUri(''), isNull);
      expect(phoneUri(' - '), isNull);
    });

    test('no phone, opened, refused', () async {
      final room = _Room();
      expect(await room.controller.callCaptain(_team('A')), CallResult.noPhone);
      expect(await room.controller.callCaptain(_team('A', phone: '0722')), CallResult.opened);
      room.phoneOpens = false;
      expect(await room.controller.callCaptain(_team('A', phone: '0722')), CallResult.failed);
    });
  });

  test('the filter and the rows follow each other', () async {
    final room = _Room();
    await room.give([_team('A', started: true), _team('B')]);
    room.controller.setFilter(BoardFilter.notStarted);
    expect(room.controller.rows(_now).map((r) => r.team.name), ['B']);
  });

  test('dispose stops listening', () async {
    final room = _Room();
    room.controller.dispose();
    expect(room.teams.hasListener, isFalse);
    expect(room.events.hasListener, isFalse);
  });
}
