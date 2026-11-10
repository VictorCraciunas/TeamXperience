import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/app_bottom_nav.dart';
import 'package:teamxperience/ui/components/navigation/app_nav_item.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';

const _items = [
  AppNavItem(icon: Icons.home_outlined, label: 'Acasă'),
  AppNavItem(icon: Icons.explore_outlined, label: 'Evenimente', showBadge: true),
  AppNavItem(icon: Icons.article_outlined, label: 'Știri'),
  AppNavItem(icon: Icons.person_outline, label: 'Profil'),
];

void main() {
  testWidgets('shows all labels', (tester) async {
    await pumpUi(
      tester,
      AppBottomNav(currentIndex: 0, onSelected: (_) {}, items: _items),
    );
    for (final label in ['Acasă', 'Evenimente', 'Știri', 'Profil']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('tapping an item reports its index', (tester) async {
    int? selected;
    await pumpUi(
      tester,
      AppBottomNav(currentIndex: 0, onSelected: (i) => selected = i, items: _items),
    );
    await tester.tap(find.text('Știri'));
    expect(selected, 2);
  });

  testWidgets('shows the badge dot only on items that ask for it', (tester) async {
    await pumpUi(
      tester,
      AppBottomNav(currentIndex: 0, onSelected: (_) {}, items: _items),
    );
    expect(find.byKey(const ValueKey('nav-badge-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-badge-0')), findsNothing);
  });

  testWidgets('marks only the current item as active', (tester) async {
    await pumpUi(
      tester,
      AppBottomNav(currentIndex: 1, onSelected: (_) {}, items: _items),
    );
    expect(find.byKey(const ValueKey('nav-active-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-active-0')), findsNothing);
  });

  testWidgets('labels stay visible at text scale 1.5 without overflow',
      (tester) async {
    await pumpUi(
      tester,
      AppBottomNav(currentIndex: 0, onSelected: (_) {}, items: _items),
      textScale: 1.5,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Evenimente'), findsOneWidget);
  });

  test('more than five items is rejected', () {
    expect(
      () => AppBottomNav(
        currentIndex: 0,
        onSelected: (_) {},
        items: List.filled(6, const AppNavItem(icon: Icons.add, label: 'x')),
      ),
      throwsAssertionError,
    );
  });

  group('five tabs with a raised centre', () {
    List<AppNavItem> five({bool live = false}) => [
          const AppNavItem(icon: Icons.home_outlined, label: 'Acasă'),
          const AppNavItem(icon: Icons.map_outlined, label: 'Evenimente'),
          AppNavItem(icon: Icons.vpn_key_outlined, label: live ? 'În joc' : 'Joacă', raised: true, live: live),
          const AppNavItem(icon: Icons.group_outlined, label: 'Echipe'),
          const AppNavItem(icon: Icons.person_outline, label: 'Profil'),
        ];

    Future<void> pumpFive(WidgetTester tester, {bool live = false, int current = 0, ValueChanged<int>? onSelected, double width = 360, double textScale = 1}) {
      return pumpUi(
        tester,
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: AppBottomNav(currentIndex: current, onSelected: onSelected ?? (_) {}, items: five(live: live)),
        ),
        width: width,
        textScale: textScale,
      );
    }

    BoxDecoration circle(WidgetTester tester) => tester
        .widget<Container>(find.byKey(const ValueKey('nav-raised-circle')))
        .decoration as BoxDecoration;

    testWidgets('shows the five labels', (tester) async {
      await pumpFive(tester);
      for (final label in ['Acasă', 'Evenimente', 'Joacă', 'Echipe', 'Profil']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('live turns the circle and its label red', (tester) async {
      await pumpFive(tester, live: true);
      expect(circle(tester).color, AppColors.light.live);
      expect(tester.widget<Text>(find.text('În joc')).style?.color, AppColors.light.live);
    });

    // The mockup's `.on i{background:#DDF3F3;border-radius:99px;padding:2px 14px}`.
    testWidgets('the active plain item gets the pill', (tester) async {
      await pumpFive(tester, current: 1);
      final pill = find.byKey(const ValueKey('nav-pill'));
      expect(pill, findsOneWidget);
    });

    testWidgets('the bar keeps its height when the raised tab is the current one', (tester) async {
      await pumpFive(tester, current: 1);
      final withPill = tester.getSize(find.byType(AppBottomNav)).height;
      await pumpFive(tester, current: 2);
      expect(find.byKey(const ValueKey('nav-pill')), findsNothing);
      expect(tester.getSize(find.byType(AppBottomNav)).height, withPill);
    });

    testWidgets('tapping the raised item reports index 2', (tester) async {
      int? selected;
      await pumpFive(tester, onSelected: (i) => selected = i);
      await tester.tap(find.byKey(const ValueKey('nav-raised-circle')));
      expect(selected, 2);
    });

    testWidgets('fits a 320 px phone at 1.3x text', (tester) async {
      await pumpFive(tester, width: 320, textScale: 1.3);
      expect(tester.takeException(), isNull);
    });
  
    group('the part of the circle above the bar', () {
      Future<(List<String>, List<int>)> pumpOverBody(WidgetTester tester) async {
        final bodyTaps = <String>[];
        final selected = <int>[];
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => bodyTaps.add('body'),
              child: const SizedBox.expand(),
            ),
            bottomNavigationBar: AppBottomNav(currentIndex: 0, onSelected: selected.add, items: five()),
          ),
        ));
        return (bodyTaps, selected);
      }

      testWidgets('takes taps near its top instead of the page behind', (tester) async {
        final (bodyTaps, selected) = await pumpOverBody(tester);
        final circleRect = tester.getRect(find.byKey(const ValueKey('nav-raised-circle')));
        final barTop = tester.getTopLeft(find.byType(AppBottomNav)).dy;
        expect(circleRect.top, lessThan(barTop));
        await tester.tapAt(Offset(circleRect.center.dx, circleRect.top + 3));
        expect(selected, [2]);
        expect(bodyTaps, isEmpty);
      });

      testWidgets('takes taps on its lower half inside the bar', (tester) async {
        final (bodyTaps, selected) = await pumpOverBody(tester);
        final circleRect = tester.getRect(find.byKey(const ValueKey('nav-raised-circle')));
        await tester.tapAt(Offset(circleRect.center.dx, circleRect.bottom - 4));
        expect(selected, [2]);
        expect(bodyTaps, isEmpty);
      });

      testWidgets('leaves the page beside it tappable', (tester) async {
        final (bodyTaps, selected) = await pumpOverBody(tester);
        final circleRect = tester.getRect(find.byKey(const ValueKey('nav-raised-circle')));
        await tester.tapAt(Offset(circleRect.left - 20, circleRect.top + 3));
        expect(bodyTaps, ['body']);
        expect(selected, isEmpty);
      });
    });
  });
}
