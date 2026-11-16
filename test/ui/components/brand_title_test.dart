import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/brand_title.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';

TextSpan _span(WidgetTester tester) => tester.widget<Text>(find.text('TeamXperience')).textSpan as TextSpan;

void main() {
  testWidgets('drawn as text: Poppins bold 20 by default, the X in the brand yellow', (tester) async {
    await pumpUi(tester, const BrandTitle());
    final title = _span(tester);
    expect(title.style?.fontSize, 20);
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(title.style?.color, AppColors.light.text);
    final x = (title.children ?? const []).whereType<TextSpan>().firstWhere((s) => s.text == 'X');
    expect(x.style?.color, AppColors.light.brandX);
  });

  testWidgets('takes a larger size, and the page text colour in dark mode', (tester) async {
    await pumpUi(tester, const BrandTitle(fontSize: 40), theme: AppTheme.dark);
    final title = _span(tester);
    expect(title.style?.fontSize, 40);
    expect(title.style?.color, AppColors.dark.text);
  });
}
