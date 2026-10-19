import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';

SvgPicture _svg(WidgetTester tester) => tester.widget<SvgPicture>(find.byType(SvgPicture));

void main() {
  testWidgets('tints with the text colour of the light theme by default', (tester) async {
    await pumpUi(tester, const AppSvgIcon('assets/images/search.svg'));
    expect(
      _svg(tester).colorFilter,
      ColorFilter.mode(AppColors.light.text, BlendMode.srcIn),
    );
  });

  testWidgets('tints with the text colour of the dark theme', (tester) async {
    await pumpUi(
      tester,
      const AppSvgIcon('assets/images/search.svg'),
      theme: AppTheme.dark,
    );
    expect(
      _svg(tester).colorFilter,
      ColorFilter.mode(AppColors.dark.text, BlendMode.srcIn),
    );
  });

  testWidgets('uses an explicit colour when given', (tester) async {
    await pumpUi(
      tester,
      const AppSvgIcon('assets/images/search.svg', color: Color(0xFF123456)),
    );
    expect(
      _svg(tester).colorFilter,
      const ColorFilter.mode(Color(0xFF123456), BlendMode.srcIn),
    );
  });

  testWidgets('applies the requested size', (tester) async {
    await pumpUi(
      tester,
      const AppSvgIcon('assets/images/search.svg', width: 19, height: 21),
    );
    expect(_svg(tester).width, 19);
    expect(_svg(tester).height, 21);
  });
}
