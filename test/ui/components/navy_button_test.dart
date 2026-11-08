import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/buttons/navy_button.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../pump_ui.dart';

Color? _fill(WidgetTester tester) {
  final ink = tester.widget<Ink>(
    find.descendant(of: find.byType(NavyButton), matching: find.byType(Ink)),
  );
  return (ink.decoration as BoxDecoration).color;
}

void main() {
  testWidgets('calls onPressed when tapped', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      NavyButton(label: 'Înscrie echipa', onPressed: () => taps++),
    );
    await tester.tap(find.text('Înscrie echipa'));
    expect(taps, 1);
  });

  testWidgets('without onPressed it is greyed out and does nothing', (
    tester,
  ) async {
    await pumpUi(
      tester,
      const NavyButton(label: 'Înscrie echipa', onPressed: null),
    );
    expect(_fill(tester), AppColors.light.insetBorder);
    expect(
      tester.widget<Text>(find.text('Înscrie echipa')).style?.color,
      AppColors.light.muted,
    );
  });

  testWidgets('while loading it shows a spinner and ignores taps', (
    tester,
  ) async {
    var taps = 0;
    await pumpUi(
      tester,
      NavyButton(
        label: 'Înscrie echipa',
        onPressed: () => taps++,
        isLoading: true,
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Înscrie echipa'), findsNothing);
    await tester.tap(find.byType(NavyButton));
    expect(taps, 0);
    expect(_fill(tester), AppColors.light.navy);
  });
}
