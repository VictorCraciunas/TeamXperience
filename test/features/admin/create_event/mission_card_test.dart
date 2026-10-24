import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/mission_list/mission_card.dart';

import '../../../ui/pump_ui.dart';

Future<void> _pump(
  WidgetTester tester, {
  int index = 0,
  int puzzles = 2,
  bool done = false,
  String status = 'Puzzle 1: lipsește tipul',
  VoidCallback? onTap,
  VoidCallback? onDelete,
}) {
  return pumpUi(
    tester,
    MissionCard(
      index: index,
      puzzleCount: puzzles,
      status: status,
      done: done,
      onTap: onTap ?? () {},
      onDelete: onDelete ?? () {},
    ),
  );
}

void main() {
  testWidgets('shows the number, the puzzle count and what is missing', (tester) async {
    await _pump(tester, index: 2, puzzles: 3);
    expect(find.text('Misiunea 3'), findsOneWidget);
    expect(find.textContaining('3 puzzle-uri'), findsOneWidget);
    expect(find.textContaining('Puzzle 1: lipsește tipul'), findsOneWidget);
  });

  testWidgets('one puzzle is singular, none says so', (tester) async {
    await _pump(tester, puzzles: 1, status: 'Gata', done: true);
    expect(find.textContaining('1 puzzle'), findsOneWidget);
    expect(find.textContaining('1 puzzle-uri'), findsNothing);
  });

  testWidgets('a finished mission shows a check', (tester) async {
    await _pump(tester, done: true, status: 'Gata');
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('an unfinished mission shows its number instead of a check', (tester) async {
    await _pump(tester);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('tapping the card opens the mission', (tester) async {
    var opened = 0;
    await _pump(tester, onTap: () => opened++);
    await tester.tap(find.text('Misiunea 1'));
    expect(opened, 1);
  });

  testWidgets('the delete button deletes and does not open', (tester) async {
    var opened = 0, deleted = 0;
    await _pump(tester, onTap: () => opened++, onDelete: () => deleted++);
    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(deleted, 1);
    expect(opened, 0);
  });

  testWidgets('the delete button is easy to hit', (tester) async {
    await _pump(tester);
    final size = tester.getSize(find.byKey(const ValueKey('delete-mission')));
    expect(size.width, greaterThanOrEqualTo(40));
    expect(size.height, greaterThanOrEqualTo(40));
  });

  testWidgets('a long status does not overflow at a large text size', (tester) async {
    await pumpUi(
      tester,
      MissionCard(
        index: 0,
        puzzleCount: 12,
        status: 'Puzzle 10: lipsește răspunsul · încă 14',
        done: false,
        onTap: () {},
        onDelete: () {},
      ),
      textScale: 1.6,
    );
    expect(tester.takeException(), isNull);
  });
}
