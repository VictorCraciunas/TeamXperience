import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_details/widgets/hero_round_button.dart';
import 'package:teamxperience/features/events_tab/widgets/events_header.dart';
import 'package:teamxperience/features/finish/widgets/rating_stars.dart';
import 'package:teamxperience/features/home/widgets/home_header.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/pill_switch.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';

import 'pump_ui.dart';

/// The app's own text stays readable on a real phone, and what can be tapped
/// is big enough for a thumb. What an organiser sets in an event is theirs.
const double _smallestText = 12;
const double _smallestTap = 44;

void main() {
  test('no text under 12 px in the app', () {
    final pattern = RegExp(r'fontSize: ([0-9.]+)');
    final problems = <String>[];
    for (final root in ['lib/features', 'lib/ui']) {
      final files = Directory(root).listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
      for (final file in files) {
        final path = file.path.replaceAll(r'\', '/');
        // The organiser's own editor holds event values, and the hidden field
        // behind the code boxes is invisible on purpose.
        if (path.contains('/create_components/') || path.endsWith('code_boxes_input.dart')) continue;
        for (final match in pattern.allMatches(file.readAsStringSync())) {
          final size = double.parse(match.group(1) ?? '0');
          if (size < _smallestText) problems.add('$path: fontSize $size');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  group('tap areas are at least 44 px high', () {
    testWidgets('the List / Map switch', (tester) async {
      await pumpUi(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: PillSwitch(
            options: const [(TablerIcons.list, 'Listă'), (TablerIcons.map_2, 'Hartă')],
            selected: 0,
            onSelected: (_) {},
          ),
        ),
      );
      expect(tester.getSize(find.byType(PillSwitch)).height, greaterThanOrEqualTo(_smallestTap));
    });

    testWidgets('a filter chip', (tester) async {
      await pumpUi(tester, Align(alignment: Alignment.topLeft, child: AppChip(label: 'Toate', onTap: () {})));
      expect(tester.getSize(find.byType(AppChip)).height, greaterThanOrEqualTo(_smallestTap));
    });

    testWidgets('a section link', (tester) async {
      await pumpUi(tester, SectionHeader(title: 'Evenimente noi', link: 'Vezi toate', onLink: () {}));
      final link = find.ancestor(of: find.text('Vezi toate'), matching: find.byType(GestureDetector)).first;
      expect(tester.getSize(link).height, greaterThanOrEqualTo(_smallestTap));
    });

    testWidgets('the bell', (tester) async {
      await pumpUi(tester, HomeHeader(unread: false, onBell: () {}));
      expect(tester.getSize(find.byKey(const ValueKey('bell'))).height, greaterThanOrEqualTo(_smallestTap));
    });

    testWidgets('a rating star', (tester) async {
      await pumpUi(tester, Center(child: RatingStars(rating: null, onRate: (_) {})));
      final star = find.ancestor(of: find.byIcon(TablerIcons.star).first, matching: find.byType(GestureDetector)).first;
      final size = tester.getSize(star);
      expect(size.width, greaterThanOrEqualTo(_smallestTap));
      expect(size.height, greaterThanOrEqualTo(_smallestTap));
    });

    testWidgets('the round button over an event\'s picture', (tester) async {
      await pumpUi(tester, Center(child: HeroRoundButton(icon: TablerIcons.share, tooltip: 'Distribuie', onTap: () {})));
      expect(tester.getSize(find.byType(HeroRoundButton)).height, greaterThanOrEqualTo(_smallestTap));
    });

    testWidgets('the search button', (tester) async {
      await pumpUi(tester, EventsHeader(mapMode: false, onMode: (_) {}, onToggleSearch: () {}));
      final search = find.ancestor(of: find.byIcon(TablerIcons.search), matching: find.byType(GestureDetector)).first;
      expect(tester.getSize(search).height, greaterThanOrEqualTo(_smallestTap));
    });
  });
}
