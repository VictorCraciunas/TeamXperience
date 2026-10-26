import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_rules/puzzle_rules_form.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_rules/puzzle_type_tile.dart';
import 'package:teamxperience/model/puzzle.dart';

import '../../../ui/pump_ui.dart';

Future<void> _pump(WidgetTester tester, Puzzle puzzle, {VoidCallback? onChanged}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await pumpUi(
    tester,
    SingleChildScrollView(child: PuzzleRulesForm(puzzle: puzzle, onChanged: onChanged)),
  );
}

Future<void> _choose(WidgetTester tester, PuzzleType type) async {
  await tester.tap(find.byType(PuzzleTypeTile));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('choice-${type.name}')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the current type', (tester) async {
    await _pump(tester, Puzzle(id: '0', type: PuzzleType.code));
    expect(find.text('Tip puzzle'), findsOneWidget);
    expect(find.descendant(of: find.byType(PuzzleTypeTile), matching: find.text('Cod')), findsOneWidget);
  });

  testWidgets('a puzzle without a type says so', (tester) async {
    await _pump(tester, Puzzle(id: '0'));
    expect(find.descendant(of: find.byType(PuzzleTypeTile), matching: find.text('Fără tip')), findsOneWidget);
  });

  testWidgets('a puzzle without a type can be given one', (tester) async {
    final puzzle = Puzzle(id: '0');
    var changes = 0;
    await _pump(tester, puzzle, onChanged: () => changes++);
    await _choose(tester, PuzzleType.code);
    expect(puzzle.type, PuzzleType.code);
    expect(find.text('Răspuns corect'), findsOneWidget);
    expect(changes, 1);
  });

  testWidgets('with nothing typed the type changes without asking', (tester) async {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code);
    await _pump(tester, puzzle);
    await _choose(tester, PuzzleType.geolocation);
    expect(find.text('Schimbi tipul?'), findsNothing);
    expect(puzzle.type, PuzzleType.geolocation);
    expect(find.text('Latitudine'), findsOneWidget);
    expect(find.text('Răspuns corect'), findsNothing);
  });

  testWidgets('with an answer typed it asks first, and Anulează keeps everything', (tester) async {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code, code: 'ABC', indiciu: 'sus');
    await _pump(tester, puzzle);
    await _choose(tester, PuzzleType.geolocation);
    expect(find.text('Schimbi tipul?'), findsOneWidget);

    await tester.tap(find.text('Anulează'));
    await tester.pumpAndSettle();
    expect(puzzle.type, PuzzleType.code);
    expect(puzzle.code, 'ABC');
    expect(puzzle.indiciu, 'sus');
  });

  testWidgets('confirming changes the type and clears the answer and the hint', (tester) async {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code, code: 'ABC', indiciu: 'sus');
    await _pump(tester, puzzle);
    await _choose(tester, PuzzleType.imageToUpload);
    await tester.tap(find.text('Schimbă'));
    await tester.pumpAndSettle();

    expect(puzzle.type, PuzzleType.imageToUpload);
    expect(puzzle.code, isNull);
    expect(puzzle.indiciu, isNull);
    expect(find.text('ABC'), findsNothing);
    expect(find.text('sus'), findsNothing);
  });

  testWidgets('choosing the type it already has does nothing', (tester) async {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code, code: 'ABC');
    await _pump(tester, puzzle);
    await _choose(tester, PuzzleType.code);
    expect(find.text('Schimbi tipul?'), findsNothing);
    expect(puzzle.code, 'ABC');
  });
}
