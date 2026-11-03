import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('content sits 1 px further in than the padding, as with a CSS border', (tester) async {
    await pumpUi(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: OutlineCard(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: SizedBox(width: 20, height: 20)),
      ),
    );
    final card = tester.getTopLeft(find.byType(OutlineCard));
    final child = tester.getTopLeft(find.byType(SizedBox).last);
    expect(child - card, const Offset(13, 11));
    expect(tester.getSize(find.byType(OutlineCard)), const Size(46, 42));
  });

  testWidgets('a panel fill, a border outline and the card radius', (tester) async {
    await pumpUi(tester, const OutlineCard(child: SizedBox(height: 10)));
    final box = tester.widget<DecoratedBox>(find.descendant(of: find.byType(OutlineCard), matching: find.byType(DecoratedBox)).first);
    final d = box.decoration as BoxDecoration;
    expect(d.color, AppColors.light.panel);
    expect((d.border as Border).top.color, AppColors.light.border);
    expect(d.borderRadius, BorderRadius.circular(14));
  });
}
