import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/choice_chip_row.dart';

import '../pump_ui.dart';

const _options = [
  ChoiceOption<int?>(3, '3'),
  ChoiceOption<int?>(5, '5'),
  ChoiceOption<int?>(null, 'Nelimitat'),
];

void main() {
  testWidgets('shows the label and every option', (tester) async {
    await pumpUi(
      tester,
      ChoiceChipRow<int?>(label: 'Încercări', options: _options, selected: null, onChanged: (_) {}),
    );
    expect(find.text('Încercări'), findsOneWidget);
    for (final text in ['3', '5', 'Nelimitat']) {
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('tapping an option reports its value', (tester) async {
    int? picked = 0;
    await pumpUi(
      tester,
      ChoiceChipRow<int?>(label: 'Încercări', options: _options, selected: null, onChanged: (v) => picked = v),
    );
    await tester.tap(find.text('5'));
    expect(picked, 5);
  });

  testWidgets('an option with a null value can be chosen', (tester) async {
    int? picked = 3;
    await pumpUi(
      tester,
      ChoiceChipRow<int?>(label: 'Încercări', options: _options, selected: 3, onChanged: (v) => picked = v),
    );
    await tester.tap(find.text('Nelimitat'));
    expect(picked, isNull);
  });

  testWidgets('exactly the selected option is marked', (tester) async {
    await pumpUi(
      tester,
      ChoiceChipRow<int?>(label: 'Încercări', options: _options, selected: 5, onChanged: (_) {}),
    );
    final selected = tester.widgetList<Semantics>(find.byType(Semantics)).where((s) => s.properties.selected == true);
    expect(selected, hasLength(1));
  });

  testWidgets('chips are easy to hit', (tester) async {
    await pumpUi(
      tester,
      ChoiceChipRow<int?>(label: 'Încercări', options: _options, selected: null, onChanged: (_) {}),
    );
    final size = tester.getSize(find.byKey(const ValueKey('chip-3')));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });
}
