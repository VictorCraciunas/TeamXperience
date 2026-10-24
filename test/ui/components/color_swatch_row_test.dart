import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/color_swatch_row.dart';

import '../pump_ui.dart';

const _swatches = ['#050805', '#0B0A24', '#E8D5A8'];

void main() {
  testWidgets('shows the label and one swatch per colour', (tester) async {
    await pumpUi(
      tester,
      ColorSwatchRow(label: 'Culoare fundal', swatches: _swatches, selected: null, onChanged: (_) {}),
    );
    expect(find.text('Culoare fundal'), findsOneWidget);
    for (final hex in _swatches) {
      expect(find.byKey(ValueKey('swatch-$hex')), findsOneWidget);
    }
  });

  testWidgets('tapping a swatch selects it', (tester) async {
    String? picked;
    await pumpUi(
      tester,
      ColorSwatchRow(label: 'Fundal', swatches: _swatches, selected: null, onChanged: (v) => picked = v),
    );
    await tester.tap(find.byKey(const ValueKey('swatch-#0B0A24')));
    expect(picked, '#0B0A24');
  });

  testWidgets('tapping the selected swatch again clears it', (tester) async {
    String? picked = 'unchanged';
    await pumpUi(
      tester,
      ColorSwatchRow(label: 'Fundal', swatches: _swatches, selected: '#050805', onChanged: (v) => picked = v),
    );
    await tester.tap(find.byKey(const ValueKey('swatch-#050805')));
    expect(picked, isNull);
  });

  testWidgets('the selected swatch is marked with a check', (tester) async {
    await pumpUi(
      tester,
      ColorSwatchRow(label: 'Fundal', swatches: _swatches, selected: '#E8D5A8', onChanged: (_) {}),
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(const ValueKey('swatch-#E8D5A8')), matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });

  testWidgets('a selected colour that is not in the list still shows', (tester) async {
    await pumpUi(
      tester,
      ColorSwatchRow(label: 'Fundal', swatches: _swatches, selected: '#123456', onChanged: (_) {}),
    );
    expect(find.byKey(const ValueKey('swatch-#123456')), findsOneWidget);
  });

  testWidgets('swatches are easy to hit', (tester) async {
    await pumpUi(
      tester,
      ColorSwatchRow(label: 'Fundal', swatches: _swatches, selected: null, onChanged: (_) {}),
    );
    final size = tester.getSize(find.byKey(const ValueKey('swatch-#050805')));
    expect(size.width, greaterThanOrEqualTo(40));
    expect(size.height, greaterThanOrEqualTo(40));
  });
}
