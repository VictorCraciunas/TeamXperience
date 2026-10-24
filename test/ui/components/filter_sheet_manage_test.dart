import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/filter_sheet.dart';

import '../pump_ui.dart';

class _Harness {
  FilterSheetResult? result;
  bool returned = false;
}

Future<_Harness> _open(
  WidgetTester tester, {
  Future<FilterOption?> Function()? onAdd,
  Future<bool> Function(FilterOption option)? onOptionLongPress,
  Map<String, String> selected = const {},
}) async {
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final h = _Harness();
  await pumpUi(
    tester,
    Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          h.result = await showFilterSheet(
            context,
            groups: [
              FilterGroup(
                id: 'category',
                title: 'Categorie',
                options: const [
                  FilterOption('Anunțuri', 'Anunțuri'),
                  FilterOption('Povești', 'Povești'),
                ],
                onAdd: onAdd,
                addTooltip: 'Adaugă categorie',
                onOptionLongPress: onOptionLongPress,
              ),
            ],
            selected: selected,
          );
          h.returned = true;
        },
        child: const Text('deschide'),
      ),
    ),
  );
  await tester.tap(find.text('deschide'));
  await tester.pumpAndSettle();
  return h;
}

void main() {
  group('the add chip', () {
    testWidgets('is a chip after the options, not an icon in the title', (tester) async {
      await _open(tester, onAdd: () async => null);
      final add = find.byKey(const ValueKey('filter-add-chip-category'));
      expect(add, findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsNothing);
      // After the last option: on the same row to its right, or on the next row.
      final last = tester.getCenter(find.text('Povești'));
      final chip = tester.getCenter(add);
      expect(chip.dy > last.dy || chip.dx > last.dx, isTrue);
    });

    testWidgets('tapping it adds and selects the new option', (tester) async {
      final h = await _open(tester, onAdd: () async => const FilterOption('Noutăți', 'Noutăți'));
      await tester.tap(find.byKey(const ValueKey('filter-add-chip-category')));
      await tester.pumpAndSettle();
      expect(find.text('Noutăți'), findsOneWidget);
      await tester.tap(find.text('Aplică'));
      await tester.pumpAndSettle();
      expect(h.result?.selected, {'category': 'Noutăți'});
    });

    testWidgets('is absent when the group cannot add', (tester) async {
      await _open(tester);
      expect(find.byKey(const ValueKey('filter-add-chip-category')), findsNothing);
    });
  });

  group('long press on an option', () {
    testWidgets('asks the group and removes the option when it was deleted', (tester) async {
      FilterOption? asked;
      await _open(
        tester,
        onOptionLongPress: (option) async {
          asked = option;
          return true;
        },
      );
      await tester.longPress(find.text('Povești'));
      await tester.pumpAndSettle();
      expect(asked?.id, 'Povești');
      expect(find.text('Povești'), findsNothing);
      expect(find.text('Anunțuri'), findsOneWidget);
    });

    testWidgets('keeps the option when it was not deleted', (tester) async {
      await _open(tester, onOptionLongPress: (_) async => false);
      await tester.longPress(find.text('Povești'));
      await tester.pumpAndSettle();
      expect(find.text('Povești'), findsOneWidget);
    });

    testWidgets('a deleted option that was selected is no longer selected', (tester) async {
      final h = await _open(
        tester,
        selected: {'category': 'Povești'},
        onOptionLongPress: (_) async => true,
      );
      await tester.longPress(find.text('Povești'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplică'));
      await tester.pumpAndSettle();
      expect(h.result?.selected, isEmpty);
    });

    testWidgets('does nothing for a group without a long-press handler', (tester) async {
      await _open(tester);
      await tester.longPress(find.text('Povești'));
      await tester.pumpAndSettle();
      expect(find.text('Povești'), findsOneWidget);
    });
  });
}
