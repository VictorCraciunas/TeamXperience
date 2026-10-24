import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_rules/puzzle_rules_form.dart';
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

void main() {
  testWidgets('a code puzzle asks for the answer, hint, attempts and message', (tester) async {
    await _pump(tester, Puzzle(id: '0', type: PuzzleType.code));
    expect(find.text('Răspuns corect'), findsOneWidget);
    expect(find.text('Indiciu (opțional)'), findsOneWidget);
    expect(find.text('Încercări'), findsOneWidget);
    expect(find.text('Mesaj la răspuns greșit (opțional)'), findsOneWidget);
    expect(find.text('Latitudine'), findsNothing);
  });

  testWidgets('a location puzzle asks for the coordinates, not an answer', (tester) async {
    await _pump(tester, Puzzle(id: '0', type: PuzzleType.geolocation));
    expect(find.text('Latitudine'), findsOneWidget);
    expect(find.text('Longitudine'), findsOneWidget);
    expect(find.text('Răspuns corect'), findsNothing);
    expect(find.text('Încercări'), findsNothing);
  });

  testWidgets('a photo puzzle explains how it is checked', (tester) async {
    await _pump(tester, Puzzle(id: '0', type: PuzzleType.imageToUpload));
    expect(find.textContaining('aprobi'), findsOneWidget);
    expect(find.text('Răspuns corect'), findsNothing);
  });

  testWidgets('typing the answer writes it onto the puzzle', (tester) async {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code);
    var changes = 0;
    await _pump(tester, puzzle, onChanged: () => changes++);
    await tester.enterText(find.widgetWithText(TextField, 'Codul pe care îl introduc jucătorii').first, ' XTREME ');
    expect(puzzle.code, 'XTREME');
    expect(changes, greaterThan(0));
  });

  testWidgets('the form starts from what the puzzle already has', (tester) async {
    await _pump(tester, Puzzle(id: '0', type: PuzzleType.code, code: 'ABC', indiciu: 'sus'));
    expect(find.text('ABC'), findsOneWidget);
    expect(find.text('sus'), findsOneWidget);
  });

  testWidgets('picking attempts and hint delay writes them onto the puzzle', (tester) async {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code);
    await _pump(tester, puzzle);
    await tester.tap(find.byKey(const ValueKey('chip-5')));
    await tester.tap(find.byKey(const ValueKey('chip-1 min')));
    expect(puzzle.maxAttempts, 5);
    expect(puzzle.hintDelaySeconds, 60);

    await tester.tap(find.byKey(const ValueKey('chip-Nelimitat')));
    expect(puzzle.maxAttempts, isNull);
  });

  testWidgets('hint delays are worded as seconds or minutes', (tester) async {
    await _pump(tester, Puzzle(id: '0', type: PuzzleType.code));
    for (final label in ['30 s', '1 min', '90 s', '3 min']) {
      expect(find.byKey(ValueKey('chip-$label')), findsOneWidget, reason: label);
    }
  });

  testWidgets('coordinates are written onto the puzzle', (tester) async {
    final puzzle = Puzzle(id: '0', type: PuzzleType.geolocation);
    await _pump(tester, puzzle);
    await tester.enterText(find.widgetWithText(TextField, 'Ex: 45.7833'), '45.78');
    await tester.enterText(find.widgetWithText(TextField, 'Ex: 24.1500'), '24.15');
    expect(puzzle.latitude, 45.78);
    expect(puzzle.longitude, 24.15);
  });
}
