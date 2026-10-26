import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_row.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_type_sheet.dart';

import '../../../ui/pump_ui.dart';

Future<void> _row(
  WidgetTester tester, {
  PuzzleType? type = PuzzleType.code,
  bool done = false,
  String status = 'Lipsește răspunsul',
  VoidCallback? onTap,
  VoidCallback? onDelete,
  double scale = 1,
}) {
  return pumpUi(
    tester,
    PuzzleRow(
      index: 1,
      type: type,
      status: status,
      done: done,
      onTap: onTap ?? () {},
      onDelete: onDelete ?? () {},
    ),
    textScale: scale,
  );
}

Widget _opener(void Function(PuzzleType? chosen) onChosen) {
  return Builder(
    builder:
        (context) => TextButton(
          onPressed: () async => onChosen(await showPuzzleTypeSheet(context)),
          child: const Text('open'),
        ),
  );
}

void main() {
  group('PuzzleRow', () {
    testWidgets('shows the number, the type and what is missing', (tester) async {
      await _row(tester, type: PuzzleType.geolocation, status: 'Lipsește locația');
      expect(find.text('Puzzle 2 · Locație'), findsOneWidget);
      expect(find.text('Lipsește locația'), findsOneWidget);
    });

    testWidgets('each type has its own name', (tester) async {
      final names = <PuzzleType?, String>{
        PuzzleType.code: 'Cod',
        PuzzleType.imageToUpload: 'Fotografie',
        PuzzleType.redirect: 'Link',
        null: 'Fără tip',
      };
      for (final entry in names.entries) {
        await _row(tester, type: entry.key);
        expect(find.textContaining(entry.value), findsOneWidget, reason: '${entry.key}');
      }
    });

    testWidgets('a ready puzzle shows a check', (tester) async {
      await _row(tester, done: true, status: 'Gata');
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tapping opens the puzzle, the bin deletes it', (tester) async {
      var opened = 0, deleted = 0;
      await _row(tester, onTap: () => opened++, onDelete: () => deleted++);
      await tester.tap(find.text('Puzzle 2 · Cod'));
      expect(opened, 1);
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, 1);
      expect(opened, 1);
    });

    testWidgets('does not overflow at a large text size', (tester) async {
      await _row(tester, status: 'Lipsește răspunsul · încă 1', scale: 1.6);
      expect(tester.takeException(), isNull);
    });
  });

  group('PuzzleTypeSheet', () {
    testWidgets('asks what kind of puzzle and offers four types', (tester) async {
      await pumpUi(tester, const PuzzleTypeSheet());
      expect(find.text('Ce fel de puzzle?'), findsOneWidget);
      for (final label in ['Cod', 'Fotografie', 'Locație', 'Link']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('choosing a type returns it', (tester) async {
      PuzzleType? chosen;
      await pumpUi(tester, _opener((c) => chosen = c));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('choice-geolocation')));
      await tester.pumpAndSettle();
      expect(chosen, PuzzleType.geolocation);
    });

    testWidgets('closing without choosing returns nothing', (tester) async {
      PuzzleType? chosen = PuzzleType.code;
      await pumpUi(tester, _opener((c) => chosen = c));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(chosen, isNull);
    });
  });
}
