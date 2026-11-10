import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_game/controller/puzzle_game_controller.dart';
import 'package:teamxperience/features/event_game/logic/preview_team.dart';
import 'package:teamxperience/features/event_game/logic/puzzle_writes.dart';
import 'package:teamxperience/features/event_game/widgets/preview_skip_view.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/model/team.dart';

import '../../ui/pump_ui.dart';

class _Recording implements PuzzleWrites {
  final calls = <String>[];

  @override
  Future<void> addWrongAttempt(String key) async => calls.add('wrong $key');
  @override
  Future<void> lockPuzzle(String key, DateTime until) async => calls.add('lock $key');
  @override
  Future<void> markHintUsed(String key) async => calls.add('hint $key');
  @override
  Future<void> updatePuzzleNumber(int puzzle) async => calls.add('puzzle $puzzle');
  @override
  Future<void> updateMissionProgress(int progress, {int? completedMission}) async => calls.add('mission $progress');
  @override
  Future<void> finishTeam() async => calls.add('finish');
  @override
  Stream<Team> watchTeam() => const Stream.empty();
}

Puzzle _code(String id) => Puzzle(id: id, type: PuzzleType.code, code: 'X');

Event _event({int puzzles = 1}) => Event(
      eventId: 'e',
      missions: [
        Mission(id: 'm', puzzles: [for (var i = 0; i < puzzles; i++) _code('$i')]),
      ],
    );

void main() {
  test('previewTeamOf is a started team, on the first mission, named for what it is', () {
    final now = DateTime(2026, 11, 8);
    final team = previewTeamOf(now: now);
    expect(team.name, 'Previzualizare');
    expect((team.hasStarted, team.hasFinished, team.missionProgress, team.puzzleNumber), (true, false, 0, 0));
    expect(team.startedAt, now);
  });

  test('the preview writes through nothing', () {
    expect(puzzleWritesFor('e', 'A', preview: true), isA<NoPuzzleWrites>());

  });

  test('NoPuzzleWrites never touches anything and streams nothing', () async {
    const writes = NoPuzzleWrites();
    await writes.addWrongAttempt('k');
    await writes.lockPuzzle('k', DateTime(2026));
    await writes.markHintUsed('k');
    await writes.updatePuzzleNumber(1);
    await writes.updateMissionProgress(1, completedMission: 0);
    await writes.finishTeam();
    expect(await writes.watchTeam().isEmpty, isTrue);
  });

  group('PuzzleGameController', () {
    Future<(PuzzleGameController, _Recording, Future<Object?>)> open(WidgetTester tester, Event event) async {
      final writes = _Recording();
      final team = previewTeamOf(now: DateTime(2026, 11, 8));
      final controller = PuzzleGameController(event.missions[0], null, event, team, 0, writes: writes);
      late Future<Object?> result;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
        return TextButton(
          onPressed: () {
            result = Navigator.of(context).push<Object?>(MaterialPageRoute(builder: (inner) {
              controller.setContext(inner);
              return const Scaffold();
            }));
          },
          child: const Text('go'),
        );
      })));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      return (controller, writes, result);
    }

    testWidgets('a wrong answer counts on the team and goes through the writes', (tester) async {
      final event = _event();
      final (controller, writes, _) = await open(tester, event);
      controller.handleCodeInput('nope');
      controller.buttonPressed(event.missions[0].puzzles[0]);
      expect(writes.calls, ['wrong 0_0']);
      expect(controller.team.attempts['0_0'], 1);
      controller.dispose();
    });

    testWidgets('the next puzzle moves the team on locally, then writes', (tester) async {
      final (controller, writes, _) = await open(tester, _event(puzzles: 2));
      controller.navigate();
      await tester.pump();
      expect(controller.selectedPuzzle, 1);
      expect(controller.team.puzzleNumber, 1);
      expect(writes.calls, ['puzzle 1']);
      controller.dispose();
    });

    testWidgets('the last mission ends with the team handed back, finished', (tester) async {
      final (controller, writes, result) = await open(tester, _event());
      controller.navigate();
      await tester.pumpAndSettle();
      expect(writes.calls, ['puzzle 0', 'mission 1', 'finish']);
      final back = await result;
      expect(back, isA<Team>());
      expect((back as Team).missionProgress, 1);
      expect(back.hasFinished, isTrue);
      controller.dispose();
    });
  });

  group('PreviewSkipView', () {
    testWidgets('says what players do, and skips', (tester) async {
      var skipped = 0;
      await pumpUi(tester, PreviewSkipView(text: 'Echipele ajung la loc.', onSkip: () => skipped++));
      expect(find.text('Echipele ajung la loc.'), findsOneWidget);
      await tester.tap(find.text('Sari peste'));
      expect(skipped, 1);
    });

    testWidgets('fits 320 px at 1.3x text', (tester) async {
      await pumpUi(tester, PreviewSkipView(text: 'Echipele ' * 30, onSkip: () {}), width: 320, textScale: 1.3);
      expect(tester.takeException(), isNull);
    });
  });
}
