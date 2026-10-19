import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

void main() {
  test('light theme carries light colours and Poppins', () {
    expect(AppTheme.light.extension<AppColors>(), AppColors.light);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'Poppins');
  });

  test('dark theme carries dark colours', () {
    expect(AppTheme.dark.extension<AppColors>(), AppColors.dark);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  testWidgets('context.colors reads the theme extension', (tester) async {
    late AppColors seen;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      home: Builder(builder: (context) {
        seen = context.colors;
        return const SizedBox();
      }),
    ));
    expect(seen, AppColors.dark);
  });

  testWidgets('context.colors falls back to light without the extension',
      (tester) async {
    late AppColors seen;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(),
      home: Builder(builder: (context) {
        seen = context.colors;
        return const SizedBox();
      }),
    ));
    expect(seen, AppColors.light);
  });
  test('themes use the page colour for scaffolds and the panel colour for canvas', () {
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.light.page);
    expect(AppTheme.light.canvasColor, AppColors.light.panel);
    expect(AppTheme.dark.scaffoldBackgroundColor, AppColors.dark.page);
    expect(AppTheme.dark.canvasColor, AppColors.dark.panel);
  });
}
