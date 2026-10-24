import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/buttons/tick_outline_button.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

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

  testWidgets('has a tick-coloured border on a panel fill in light and dark', (tester) async {
    for (final entry in {AppTheme.light: AppColors.light, AppTheme.dark: AppColors.dark}.entries) {
      await pumpUi(
        tester,
        TickOutlineButton(label: 'Creează', icon: Icons.add, onTap: () {}),
        theme: entry.key,
      );
      await tester.pumpAndSettle();
      final box = tester.widget<DecoratedBox>(find.byKey(const ValueKey('tick-outline-button-box')));
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.color, entry.value.panel);
      expect((decoration.border as Border).top.color, entry.value.tick);
    }
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
