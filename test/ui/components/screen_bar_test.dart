import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/screen_bar.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, ScreenBar bar) {
  return tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: Scaffold(appBar: bar)),
  );
}

ScreenBar _bar({String? subtitle, VoidCallback? onLeading}) => ScreenBar(
  leadingIcon: TablerIcons.x,
  onLeading: onLeading ?? () {},
  title: 'Înscrie echipa',
  subtitle: subtitle,
);

void main() {
  testWidgets('shows the title, the subtitle and the leading icon', (
    tester,
  ) async {
    await _pump(tester, _bar(subtitle: 'Moștenirea Cartografului · 14 nov'));
    expect(find.text('Înscrie echipa'), findsOneWidget);
    expect(find.text('Moștenirea Cartografului · 14 nov'), findsOneWidget);
    expect(find.byIcon(TablerIcons.x), findsOneWidget);
    expect(tester.widget<Icon>(find.byIcon(TablerIcons.x)).size, 18);
  });

  testWidgets('without a subtitle it shows only the title', (tester) async {
    await _pump(tester, _bar());
    expect(find.text('Înscrie echipa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the leading icon calls onLeading', (tester) async {
    var taps = 0;
    await _pump(tester, _bar(onLeading: () => taps++));
    await tester.tap(find.byIcon(TablerIcons.x));
    expect(taps, 1);
  });

  testWidgets('it is a panel with a 1 px border underneath', (tester) async {
    await _pump(tester, _bar(subtitle: 'x'));
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(ScreenBar),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, AppColors.light.panel);
    final border = decoration.border as Border;
    expect(border.bottom.color, AppColors.light.border);
    expect(border.bottom.width, 1);
    expect(border.top, BorderSide.none);
  });

  testWidgets('title is 12 px medium, subtitle 11 px muted', (tester) async {
    await _pump(tester, _bar(subtitle: 'Sub'));
    final title = tester.widget<Text>(find.text('Înscrie echipa')).style;
    expect(title?.fontSize, 12);
    expect(title?.fontWeight, FontWeight.w500);
    final sub = tester.widget<Text>(find.text('Sub')).style;
    expect(sub?.fontSize, 11);
    expect(sub?.color, AppColors.light.muted);
  });

  testWidgets('the bar is as tall as its content: 12 + text + 13', (
    tester,
  ) async {
    await _pump(tester, _bar(subtitle: 'Sub'));
    final height = tester.getSize(find.byType(ScreenBar)).height;
    expect(height, closeTo(12 + 12 * 1.45 + 11 * 1.45 + 13, 1));
    expect(
      height,
      lessThanOrEqualTo(_bar(subtitle: 'Sub').preferredSize.height),
    );
  });

  testWidgets('it keeps clear of the status bar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: const EdgeInsets.only(top: 30)),
              child: child ?? const SizedBox.shrink(),
            ),
        home: Scaffold(appBar: _bar(subtitle: 'Sub')),
      ),
    );
    final iconTop = tester.getTopLeft(find.byIcon(TablerIcons.x)).dy;
    expect(iconTop, greaterThanOrEqualTo(30 + 12));
  });

  for (final scale in [1.15, 1.3]) {
    testWidgets('title and subtitle fit at text scale $scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child ?? const SizedBox.shrink(),
              ),
          home: Scaffold(appBar: _bar(subtitle: 'Sub')),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
