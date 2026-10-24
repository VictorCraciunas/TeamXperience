import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/screen/puzzle_page.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

AddMissionsController _controller(Puzzle puzzle) {
  final event = Event(eventId: 'e', name: 'Hunt', missions: [Mission(id: '0', puzzles: [puzzle])])
    ..nrMissions = 1;
  return AddMissionsController(event, 'create');
}

Future<void> _pump(WidgetTester tester, Puzzle puzzle) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: PuzzlePage(controller: _controller(puzzle), mission: 0, index: 0),
    ),
  );
}

void main() {
  testWidgets('the title is in the app bar and the type under it', (tester) async {
    await _pump(tester, Puzzle(id: '0', type: PuzzleType.code));
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Puzzle 1')), findsOneWidget);
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Cod')), findsOneWidget);
  });

  testWidgets('Aspect and Reguli are below the app bar, not inside it', (tester) async {
    await _pump(tester, Puzzle(id: '0', type: PuzzleType.code));
    expect(find.text('Aspect'), findsOneWidget);
    expect(find.text('Reguli'), findsOneWidget);
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Aspect')), findsNothing);
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Reguli')), findsNothing);
  });

  testWidgets('it opens on Aspect and Reguli switches to the rules', (tester) async {
    await _pump(tester, Puzzle(id: '0', type: PuzzleType.code));
    expect(find.text('Adaugă componentă'), findsOneWidget);
    expect(find.text('Răspuns corect').hitTestable(), findsNothing);

    await tester.tap(find.text('Reguli'));
    await tester.pump();
    expect(find.text('Răspuns corect').hitTestable(), findsOneWidget);
  });

  testWidgets('what is typed in Reguli is kept when going back to Aspect', (tester) async {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code);
    await _pump(tester, puzzle);
    await tester.tap(find.text('Reguli'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Codul pe care îl introduc jucătorii'), 'XTREME');
    await tester.tap(find.text('Aspect'));
    await tester.pump();
    await tester.tap(find.text('Reguli'));
    await tester.pump();
    expect(find.text('XTREME'), findsOneWidget);
    expect(puzzle.code, 'XTREME');
  });
}
