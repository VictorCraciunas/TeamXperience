import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../pump_ui.dart';

BoxDecoration _decoration(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: find.byType(AppChip), matching: find.byType(DecoratedBox)).first,
  );
  return box.decoration as BoxDecoration;
}

void main() {
  testWidgets('shows its label and icon', (tester) async {
    await pumpUi(tester, const AppChip(label: 'Coduri', icon: TablerIcons.key));
    expect(find.text('Coduri'), findsOneWidget);
    expect(find.byIcon(TablerIcons.key), findsOneWidget);
  });

  testWidgets('a tap calls onTap', (tester) async {
    var taps = 0;
    await pumpUi(tester, AppChip(label: 'Luna asta', onTap: () => taps++));
    await tester.tap(find.text('Luna asta'));
    expect(taps, 1);
  });

  testWidgets('plain uses the panel fill and border outline', (tester) async {
    await pumpUi(tester, const AppChip(label: 'Luna asta'));
    final d = _decoration(tester);
    expect(d.color, AppColors.light.panel);
    expect((d.border as Border).top.color, AppColors.light.border);
  });

  testWidgets('selected is filled navy', (tester) async {
    await pumpUi(tester, const AppChip(label: 'Toate', style: AppChipStyle.selected));
    expect(_decoration(tester).color, AppColors.light.navy);
    expect(tester.widget<Text>(find.text('Toate')).style?.color, AppColors.light.onNavy);
  });

  testWidgets('outlined has a tick border and accent label', (tester) async {
    await pumpUi(tester, const AppChip(label: 'Hartă', style: AppChipStyle.outlined));
    expect((_decoration(tester).border as Border).top.color, AppColors.light.tick);
    expect(tester.widget<Text>(find.text('Hartă')).style?.color, AppColors.light.accent);
  });

  testWidgets('a tappable chip has a hit area at least 32 tall', (tester) async {
    await pumpUi(tester, AppChip(label: 'Toate', onTap: () {}));
    expect(tester.getSize(find.byType(AppChip)).height, greaterThanOrEqualTo(32));
  });

  testWidgets('a chip is as tall as in the mockup (11 x 1.45 + 2 x 3 + 2 x 1 border)', (tester) async {
    await pumpUi(tester, const Align(alignment: Alignment.topLeft, child: AppChip(label: 'A')));
    expect(tester.getSize(find.byType(AppChip)).height, closeTo(23.95, 0.5));
  });
}
