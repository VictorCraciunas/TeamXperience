import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('a panel with the 17 px title, a 1 px line under it and room for the border', (tester) async {
    await pumpUi(tester, const Align(alignment: Alignment.topLeft, child: TabHeader(title: 'Joacă')));
    final title = tester.widget<Text>(find.text('Joacă')).style;
    expect((title?.fontSize, title?.fontWeight), (17, FontWeight.w500));
    final box = tester.widget<DecoratedBox>(find.descendant(of: find.byType(TabHeader), matching: find.byType(DecoratedBox)).first);
    final d = box.decoration as BoxDecoration;
    expect(d.color, AppColors.light.panel);
    expect((d.border as Border).bottom.color, AppColors.light.border);
    // 12 + one 17 px line at 1.45 + 12 + the 1 px border.
    expect(tester.getSize(find.byType(TabHeader)).height, closeTo(12 + 17 * 1.45 + 12 + 1, 0.6));
  });

  testWidgets('shows a trailing widget and a row under the title, 10 px below', (tester) async {
    await pumpUi(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: TabHeader(title: 'Evenimente', trailing: Text('T'), bottom: SizedBox(key: ValueKey('b'), height: 20)),
      ),
    );
    expect(find.text('T'), findsOneWidget);
    final titleBottom = tester.getBottomLeft(find.text('Evenimente')).dy;
    expect(tester.getTopLeft(find.byKey(const ValueKey('b'))).dy - titleBottom, closeTo(10, 0.6));
  });
}
