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
  _mockupStyles();

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

void _mockupStyles() {
  testWidgets('the mockup styles have the mockup sizes', (tester) async {
    late Map<String, TextStyle> s;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            s = {
              'heroTitle': AppTextStyles.heroTitle(context),
              'trailHeading': AppTextStyles.trailHeading(context),
              'cardTitle': AppTextStyles.cardTitle(context),
              'pageBody': AppTextStyles.pageBody(context),
              'smallMuted': AppTextStyles.smallMuted(context),
              'factValue': AppTextStyles.factValue(context),
              'display': AppTextStyles.display(context),
            };
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    const expected = {
      'heroTitle': (19.0, FontWeight.w500, 1.2),
      'trailHeading': (14.0, FontWeight.w500, null),
      'cardTitle': (12.0, FontWeight.w500, null),
      'pageBody': (12.0, FontWeight.w400, 1.45),
      'smallMuted': (11.0, FontWeight.w400, 1.45),
      'factValue': (18.0, FontWeight.w500, 1.0),
      'display': (34.0, FontWeight.w500, 1.0),
    };
    for (final e in expected.entries) {
      final style = s[e.key];
      expect(style?.fontSize, e.value.$1, reason: e.key);
      expect(style?.fontWeight, e.value.$2, reason: e.key);
      expect(style?.height, e.value.$3, reason: e.key);
    }
    expect(s['smallMuted']?.color, AppColors.light.muted);
    expect(s['cardTitle']?.color, AppColors.light.text);
  });
}
