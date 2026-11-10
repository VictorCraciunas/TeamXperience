import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/app_bottom_nav.dart';
import 'package:teamxperience/ui/components/navigation/app_nav_item.dart';
import 'package:teamxperience/ui/components/navigation/sonar_rings.dart';

import '../pump_ui.dart';

List<AppNavItem> _five({required bool live}) => [
      const AppNavItem(icon: Icons.home_outlined, label: 'Acasă'),
      const AppNavItem(icon: Icons.map_outlined, label: 'Evenimente'),
      AppNavItem(icon: Icons.play_arrow, label: live ? 'În joc' : 'Joacă', raised: true, live: live),
      const AppNavItem(icon: Icons.group_outlined, label: 'Echipe'),
      const AppNavItem(icon: Icons.person_outline, label: 'Profil'),
    ];

Widget _bar({required bool live, bool reduced = false}) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: AppBottomNav(currentIndex: 0, onSelected: (_) {}, items: _five(live: live)),
        ),
      ),
    );

void main() {
  test('a ring leaves the circle at 80 % and fades out at 1.7 times its size', () {
    expect(sonarRing(0), (scale: 1.0, opacity: .8));
    expect(sonarRing(1), (scale: 1.7, opacity: 0.0));
    final half = sonarRing(.5);
    expect(half.scale, greaterThan(1.35), reason: 'ease-out: past half way at half time');
    expect(half.opacity, lessThan(.4));
  });

  test('the second ring is half a beat behind the first', () {
    expect(sonarPhases(0), [0.0, 0.5]);
    expect(sonarPhases(.75), [.75, .25]);
  });

  testWidgets('while live, sonar rings leave the red circle', (tester) async {
    await pumpUi(tester, _bar(live: true));
    expect(find.byType(SonarRings), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('no rings when not live', (tester) async {
    await pumpUi(tester, _bar(live: false));
    expect(find.byType(SonarRings), findsNothing);
  });

  testWidgets('no rings with reduced motion', (tester) async {
    await pumpUi(tester, _bar(live: true, reduced: true));
    expect(find.byType(SonarRings), findsNothing);
  });
}
