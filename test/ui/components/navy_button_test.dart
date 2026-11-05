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
  testWidgets('is navy with on-navy text, 12 radius and 11 px of padding', (
    tester,
  ) async {
    await pumpUi(tester, NavyButton(label: 'Înscrie echipa', onPressed: () {}));
    expect(_fill(tester), AppColors.light.navy);
    final text = tester.widget<Text>(find.text('Înscrie echipa'));
    expect(text.style?.color, AppColors.light.onNavy);
    expect(text.style?.fontWeight, FontWeight.w500);
    expect(text.style?.fontSize, 12);
    final ink = tester.widget<Ink>(find.byType(Ink));
    expect(
      (ink.decoration as BoxDecoration).borderRadius,
      BorderRadius.circular(12),
    );
    expect(
      tester.getSize(find.byType(NavyButton)).height,
      closeTo(22 + 12 * 1.45, .5),
    );
  });

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
