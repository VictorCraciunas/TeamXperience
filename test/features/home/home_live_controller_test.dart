import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/controller/home_live_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

Team _team(String name, int progress) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      missionProgress: progress,
      hasStarted: true,
    );

Event _event(String id) => Event(eventId: id, name: id)..nrMissions = 6;

void main() {
  late Map<String, StreamController<List<Team>>> streams;
  late HomeLiveController controller;

  setUp(() {
    streams = {};
    controller = HomeLiveController(
      teams: (id) => (streams[id] = StreamController<List<Team>>()).stream,
    );
  });

  tearDown(() => controller.dispose());

  test('ranks the teams that arrive', () async {
    controller.watch(_event('e1'));
    streams['e1']?.add([_team('Lupii', 3), _team('Bufnițele', 4)]);
    await pumpEventQueue();
    expect([for (final r in controller.ranked) r.team.name], ['Bufnițele', 'Lupii']);
    expect(controller.ranked.first.mission, 5);
    expect(controller.own('Lupii')?.missionProgress, 3);
    expect(controller.own('Altă'), isNull);
  });

  test('watching another event cancels the first stream', () async {
    controller.watch(_event('e1'));
    await pumpEventQueue();
    expect(streams['e1']?.hasListener, isTrue);
    controller.watch(_event('e2'));
    await pumpEventQueue();
    expect(streams['e1']?.hasListener, isFalse);
    expect(streams['e2']?.hasListener, isTrue);
  });

  test('watching the same event again keeps its stream', () async {
    controller.watch(_event('e1'));
    final first = streams['e1'];
    controller.watch(_event('e1'));
    expect(identical(streams['e1'], first), isTrue);
    expect(first?.hasListener, isTrue);
  });

  test('watching nothing clears the teams', () async {
    controller.watch(_event('e1'));
    streams['e1']?.add([_team('Lupii', 3)]);
    await pumpEventQueue();
    controller.watch(null);
    expect(controller.ranked, isEmpty);
    expect(streams['e1']?.hasListener, isFalse);
  });

  test('a stream error leaves no teams and does not throw', () async {
    controller.watch(_event('e1'));
    streams['e1']?.add([_team('Lupii', 3)]);
    await pumpEventQueue();
    streams['e1']?.addError(Exception('offline'));
    await pumpEventQueue();
    expect(controller.ranked, isEmpty);
  });

  test('tells its listeners when teams arrive', () async {
    var calls = 0;
    controller.addListener(() => calls++);
    controller.watch(_event('e1'));
    streams['e1']?.add([_team('Lupii', 3)]);
    await pumpEventQueue();
    expect(calls, greaterThan(0));
  });

  test('a change that does not move the board (a new location) tells nobody', () async {
    controller.watch(_event('e1'));
    streams['e1']?.add([_team('Lupii', 3), _team('Bufnițele', 4)]);
    await pumpEventQueue();
    var calls = 0;
    controller.addListener(() => calls++);
    streams['e1']?.add([_team('Lupii', 3)..latitude = 45.8, _team('Bufnițele', 4)..longitude = 24.2]);
    await pumpEventQueue();
    expect(calls, 0);
    streams['e1']?.add([_team('Lupii', 5), _team('Bufnițele', 4)]);
    await pumpEventQueue();
    expect(calls, 1);
    expect(controller.ranked.first.team.name, 'Lupii');
  });

  test('a new presence time does tell its listeners', () async {
    controller.watch(_event('e1'));
    streams['e1']?.add([_team('Lupii', 3)]);
    await pumpEventQueue();
    var calls = 0;
    controller.addListener(() => calls++);
    final seen = Team.fromMap({'name': 'Lupii', 'missionProgress': 3, 'hasStarted': true})
      ..presence['u1'] = DateTime(2026, 11, 14, 11);
    streams['e1']?.add([seen]);
    await pumpEventQueue();
    expect(calls, 1);
  });
}
