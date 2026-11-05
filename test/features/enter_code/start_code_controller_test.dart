import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/enter_code/controller/start_code_controller.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

Team _team({bool started = false}) => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Victor',
      phoneNumber: '',
      captainEmail: '',
      hasStarted: started,
    );

void main() {
  final event = Event(eventId: 'e1', startCode: 'HARTA', dateEvent: DateTime(2026, 11, 14, 10));
  final during = DateTime(2026, 11, 14, 10, 18);

  late StreamController<Team> stream;
  late List<String> log;
  late Team? found;

  StartCodeController make() => StartCodeController(
        event: event,
        findTeam: () async => found,
        watchTeam: (name) {
          log.add('watch:$name');
          return stream.stream;
        },
        startTeam: (t) async => log.add('start:${t.name}'),
        onEnter: (e, t) async => log.add('enter:${t.name}'),
        clock: () => during,
      );

  setUp(() {
    stream = StreamController<Team>.broadcast();
    log = [];
    found = _team();
  });

  tearDown(() => stream.close());

  test('load finds the team, then follows it', () async {
    final c = make();
    await c.load();
    expect(c.team?.name, 'Vulpile');
    expect(log, ['watch:Vulpile']);
    c.dispose();
  });

  test('a wrong code is refused and kept', () async {
    final c = make();
    await c.load();
    c.setCode('HARTI');
    await c.submit();
    expect(c.result, StartCodeResult.wrong);
    expect(c.code, 'HARTI');
    expect(log, isNot(contains('enter:Vulpile')));
    c.setCode('HART');
    expect(c.result, isNull, reason: 'editing clears the message');
    c.dispose();
  });

  test('a right code starts the team once and enters once, even with two quick taps', () async {
    final c = make();
    await c.load();
    c.setCode('harta');
    await Future.wait([c.submit(), c.submit()]);
    await pumpEventQueue();
    expect(log.where((l) => l == 'start:Vulpile'), hasLength(1));
    expect(log.where((l) => l == 'enter:Vulpile'), hasLength(1));
    expect(c.result, isNull);
    c.dispose();
  });

  test('when the stream says the team started, the typed code clears and the code is not needed', () async {
    final c = make();
    await c.load();
    c.setCode('HAR');
    stream.add(_team(started: true));
    await pumpEventQueue();
    expect(c.started, isTrue);
    expect(c.code, '');
    expect(c.result, isNull);
    await c.submit();
    expect(log, ['watch:Vulpile', 'enter:Vulpile']);
    c.dispose();
  });

  test('no team: a right code says so', () async {
    found = null;
    final c = make();
    await c.load();
    expect(c.team, isNull);
    c.setCode('HARTA');
    await c.submit();
    expect(c.result, StartCodeResult.noTeam);
    expect(log, isEmpty);
    c.dispose();
  });

  test('a failed lookup on open leaves no team and does not throw', () async {
    final c = StartCodeController(
      event: event,
      findTeam: () async => throw Exception('offline'),
      watchTeam: (_) => stream.stream,
      startTeam: (_) async {},
      onEnter: (_, _) async {},
      clock: () => during,
    );
    await c.load();
    expect(c.team, isNull);
    c.dispose();
  });

  test('dispose stops following the team', () async {
    final c = make();
    await c.load();
    expect(stream.hasListener, isTrue);
    c.dispose();
    expect(stream.hasListener, isFalse);
  });

  test('closing the screen while entering does not throw', () async {
    late StartCodeController c;
    c = StartCodeController(
      event: event,
      findTeam: () async => found,
      watchTeam: (_) => stream.stream,
      startTeam: (_) async {},
      onEnter: (_, _) async => c.dispose(),
      clock: () => during,
    );
    await c.load();
    c.setCode('HARTA');
    await c.submit();
  });
}
