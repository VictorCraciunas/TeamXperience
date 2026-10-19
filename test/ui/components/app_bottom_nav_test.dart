import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/app_bottom_nav.dart';
import 'package:teamxperience/ui/components/navigation/app_nav_item.dart';

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

  test('more than four items is rejected', () {
    expect(
      () => AppBottomNav(
        currentIndex: 0,
        onSelected: (_) {},
        items: List.filled(5, const AppNavItem(icon: Icons.add, label: 'x')),
      ),
      throwsAssertionError,
    );
  });
}
