import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/screen_bar.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

/// Screens put the bar at the top of their body, so it is exactly as tall as
/// its content at every text size.
Future<void> _pump(WidgetTester tester, ScreenBar bar) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Column(
          children: [
            bar,
            const Expanded(child: SizedBox(key: ValueKey('body'))),
          ],
        ),
      ),
    ),
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
        home: Scaffold(body: Column(children: [_bar(subtitle: 'Sub')])),
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
          home: Scaffold(body: Column(children: [_bar(subtitle: 'Sub')])),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }

  test('is not an app bar, so it cannot be given a slot it does not fill', () {
    expect(_bar(), isNot(isA<PreferredSizeWidget>()));
  });

  for (final scale in [1.0, 1.15, 1.3]) {
    testWidgets('no gap between the bar and the page at text scale $scale', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(tester, _bar(subtitle: 'Moștenirea Cartografului · 14 nov'));
      final barBottom = tester.getBottomLeft(find.byType(ScreenBar)).dy;
      final bodyTop = tester.getTopLeft(find.byKey(const ValueKey('body'))).dy;
      expect(bodyTop, barBottom);
      expect(tester.takeException(), isNull);
    });
  }
}
