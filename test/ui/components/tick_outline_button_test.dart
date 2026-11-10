import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/buttons/tick_outline_button.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('shows the icon and label and reports taps', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      TickOutlineButton(label: 'Creează știre', icon: Icons.add, onTap: () => taps++),
    );
    expect(find.text('Creează știre'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.text('Creează știre'));
    expect(taps, 1);
  });

  testWidgets('is 48 high and fits a narrow row at large text', (tester) async {
    await pumpUi(
      tester,
      TickOutlineButton(label: 'Creează eveniment', icon: Icons.add, onTap: () {}),
      width: 180,
      textScale: 1.5,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const ValueKey('tick-outline-button-box'))).height, greaterThanOrEqualTo(48));
  });
}
