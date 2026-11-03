import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_flow.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

void main() {
  final event = Event(eventId: 'e1', startCode: 'HARTI', dateEvent: DateTime(2026, 11, 14, 10));
  final now = DateTime(2026, 11, 14, 10, 20);
  final team = Team(name: 'Vulpile', teamMembers: '', captainName: 'V', phoneNumber: '', captainEmail: '', numberOfMembers: 4);

  test('a right code with a team starts it and returns ok', () async {
    final started = <String>[];
    final flow = StartCodeFlow(findTeam: () async => team, startTeam: (t) async => started.add(t.name));
    final result = await flow.submit(input: 'harti', event: event, now: now);
    expect(result, (StartCodeResult.ok, team));
    expect(started, ['Vulpile']);
  });

  test('a right code without a team says so', () async {
    final flow = StartCodeFlow(findTeam: () async => null, startTeam: (_) async {});
    final result = await flow.submit(input: 'HARTI', event: event, now: now);
    expect(result?.$1, StartCodeResult.noTeam);
  });

  test('a failing team lookup reports failed', () async {
    final flow = StartCodeFlow(findTeam: () async => throw Exception('offline'), startTeam: (_) async {});
    final result = await flow.submit(input: 'HARTI', event: event, now: now);
    expect(result?.$1, StartCodeResult.failed);
  });

  test('the game opens without waiting for the start to reach the server', () async {
    final never = Completer<void>();
    final flow = StartCodeFlow(findTeam: () async => team, startTeam: (_) => never.future);
    final result = await flow.submit(input: 'HARTI', event: event, now: now);
    expect(result?.$1, StartCodeResult.ok);
  });

  test('a start that fails later does not throw', () async {
    final flow = StartCodeFlow(findTeam: () async => team, startTeam: (_) async => throw Exception('denied'));
    final result = await flow.submit(input: 'HARTI', event: event, now: now);
    expect(result?.$1, StartCodeResult.ok);
    await pumpEventQueue();
  });

  test('a second tap while the first is running is ignored', () async {
    final lookup = Completer<Team?>();
    final flow = StartCodeFlow(findTeam: () => lookup.future, startTeam: (_) async {});
    final first = flow.submit(input: 'HARTI', event: event, now: now);
    final second = await flow.submit(input: 'HARTI', event: event, now: now);
    expect(second, isNull);
    lookup.complete(team);
    expect((await first)?.$1, StartCodeResult.ok);
    expect((await flow.submit(input: 'HARTI', event: event, now: now))?.$1, StartCodeResult.ok);
  });

  test('a wrong code never looks up the team', () async {
    var lookups = 0;
    final flow = StartCodeFlow(findTeam: () async { lookups++; return team; }, startTeam: (_) async {});
    final result = await flow.submit(input: 'HARTA', event: event, now: now);
    expect(result?.$1, StartCodeResult.wrong);
    expect(lookups, 0);
  });
}
