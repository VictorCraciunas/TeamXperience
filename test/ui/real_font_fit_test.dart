import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/home/widgets/home_header.dart';
import 'package:teamxperience/features/home/widgets/next_game_card.dart';
import 'package:teamxperience/features/home/widgets/recommended_card.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/ui/components/event/date_fact_tile.dart';
import 'package:teamxperience/ui/components/event/fact_row.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/components/navigation/app_bottom_nav.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';

import 'pump_ui.dart';

/// Tests normally draw with a square placeholder font, which says nothing
/// about whether words really fit. These load the app's Poppins and check the
/// things that have gone wrong on an ordinary 360 px phone.
Future<void> _loadPoppins() async {
  for (final file in ['Regular', 'Medium', 'SemiBold']) {
    final loader = FontLoader('Poppins')..addFont(rootBundle.load('assets/fonts/Poppins-$file.ttf'));
    await loader.load();
  }
}

bool _cut(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).didExceedMaxLines;

void main() {
  setUpAll(_loadPoppins);

  testWidgets('"Evenimente" in the tab bar keeps almost its full size', (tester) async {
    await pumpUi(
      tester,
      Align(
        alignment: Alignment.bottomCenter,
        child: AppBottomNav(currentIndex: PlayerTab.events, onSelected: (_) {}, items: playerNavItems(live: false)),
      ),
    );
    final label = find.text('Evenimente');
    final drawn = tester.getTopRight(label).dx - tester.getTopLeft(label).dx;
    expect(drawn, greaterThan(65));
  });

  testWidgets('"Echipă completă" is not cut on the next-game card', (tester) async {
    await pumpUi(
      tester,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: NextGameCard(event: sampleEvent(), left: const Duration(days: 4), now: DateTime(2026, 11, 10), team: sampleTeam(), onTap: () {}),
      ),
    );
    expect(_cut(tester, 'Echipă completă'), isFalse);
    expect(_cut(tester, 'Cod de start'), isFalse);
  });

  testWidgets('"Recomandat pentru tine" is not cut next to the route facts', (tester) async {
    await pumpUi(
      tester,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: RecommendedCard(event: sampleEvent(), onRegister: () {}),
      ),
    );
    expect(_cut(tester, 'Recomandat pentru tine'), isFalse);
  });

  testWidgets('the date tile keeps its month and time on one line', (tester) async {
    await pumpUi(
      tester,
      const FactRow(date: DateFactTile(day: '14', detail: 'nov · 10:00'), facts: []),
    );
    expect(tester.getSize(find.text('nov · 10:00')).height, lessThan(25));
  });

  testWidgets('the bell\'s dot sits on the bell', (tester) async {
    await pumpUi(tester, HomeHeader(unread: true, onBell: () {}));
    final bell = tester.getRect(find.byIcon(TablerIcons.bell));
    final dot = tester.getRect(find.byKey(const ValueKey('bell-dot')));
    expect(dot.overlaps(bell), isTrue);
  });

  testWidgets('tab titles sit at the same height with or without a button', (tester) async {
    double centre(String title) => tester.getCenter(find.text(title)).dy;

    await pumpUi(tester, const Align(alignment: Alignment.topCenter, child: TabHeader(title: 'Echipe')));
    final plain = centre('Echipe');
    await pumpUi(
      tester,
      const Align(alignment: Alignment.topCenter, child: TabHeader(title: 'Profil', trailing: SizedBox.square(dimension: 44))),
    );
    expect(centre('Profil'), plain);
    await pumpUi(tester, Align(alignment: Alignment.topCenter, child: HomeHeader(unread: false, onBell: () {})));
    expect(centre('TeamXperience'), plain);
  });

  testWidgets('a short section link is wide enough to tap', (tester) async {
    await pumpUi(tester, SectionHeader(title: 'Clasament live', link: 'Tot', onLink: () {}));
    final link = find.ancestor(of: find.text('Tot'), matching: find.byType(GestureDetector)).first;
    expect(tester.getSize(link).width, greaterThanOrEqualTo(44));
  });
}
