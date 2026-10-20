import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<Map<String, TextStyle>> _styles(WidgetTester tester, ThemeData theme) async {
  late Map<String, TextStyle> result;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          result = {
            'headline': AppTextStyles.headline(context),
            'sectionTitle': AppTextStyles.sectionTitle(context),
            'title': AppTextStyles.title(context),
            'body': AppTextStyles.body(context),
            'bodyMuted': AppTextStyles.bodyMuted(context),
            'caption': AppTextStyles.caption(context),
            'label': AppTextStyles.label(context),
            'button': AppTextStyles.button(context),
            'wordmark': AppTextStyles.wordmark(context),
          };
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('styles have the sizes and weights of the approved screens', (tester) async {
    final s = await _styles(tester, AppTheme.light);
    expect(s['sectionTitle']!.fontSize, 15);
    expect(s['sectionTitle']!.fontWeight, FontWeight.w600);
    expect(s['caption']!.fontSize, 11);
    expect(s['button']!.fontSize, 14);
    expect(s['button']!.fontWeight, FontWeight.w600);
    expect(s['wordmark']!.fontSize, 18);
    expect(s['wordmark']!.fontWeight, FontWeight.w700);
    expect(s['body']!.fontWeight, FontWeight.w400);
  });

  testWidgets('muted styles follow the active theme', (tester) async {
    final light = await _styles(tester, AppTheme.light);
    expect(light['bodyMuted']!.color, AppColors.light.muted);
    expect(light['body']!.color, AppColors.light.text);

    final dark = await _styles(tester, AppTheme.dark);
    expect(dark['bodyMuted']!.color, AppColors.dark.muted);
    expect(dark['caption']!.color, AppColors.dark.muted);
  });

  testWidgets('styles never set a font family', (tester) async {
    final s = await _styles(tester, AppTheme.light);
    for (final entry in s.entries) {
      expect(entry.value.fontFamily, isNull, reason: entry.key);
    }
  });

  testWidgets('the theme text theme carries the same section title and body', (tester) async {
    final theme = AppTheme.light;
    expect(theme.textTheme.titleMedium!.fontSize, 15);
    expect(theme.textTheme.bodyMedium!.fontSize, 13);
  });
}
