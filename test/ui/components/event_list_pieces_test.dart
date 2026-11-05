import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/event/open_event_card.dart';
import 'package:teamxperience/ui/components/event/registered_event_tile.dart';
import 'package:teamxperience/ui/components/misc/pill_switch.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';

Widget _tile({VoidCallback? onTap}) => RegisteredEventTile(
      day: '14',
      month: 'nov',
      title: 'Moștenirea Cartografului',
      subtitle: 'Vulpile · peste 3 zile',
      badge: 'Înscriși',
      onTap: onTap ?? () {},
    );

Widget _card({VoidCallback? onTap, VoidCallback? onShare, String? badge = 'Mai sunt 2 locuri'}) => OpenEventCard(
      badge: badge,
      title: 'Protocolul Cerber',
      date: 'Sâm 21 nov',
      facts: '3,2 km · 1 h 30',
      onTap: onTap ?? () {},
      onShare: onShare ?? () {},
    );

void main() {
  group('SectionHeader', () {
    testWidgets('title 14 w500 with a muted count at the right', (tester) async {
      await pumpUi(tester, const SectionHeader(title: 'Deschise pentru înscriere', trailing: '4'));
      final t = tester.widget<Text>(find.text('Deschise pentru înscriere')).style;
      expect((t?.fontSize, t?.fontWeight), (14, FontWeight.w500));
      expect(tester.widget<Text>(find.text('4')).style?.color, AppColors.light.muted);
    });

    testWidgets('a link calls back', (tester) async {
      var taps = 0;
      await pumpUi(tester, SectionHeader(title: 'Știri', link: 'Vezi toate', onLink: () => taps++));
      expect(tester.widget<Text>(find.text('Vezi toate')).style?.color, AppColors.light.accent);
      await tester.tap(find.text('Vezi toate'));
      expect(taps, 1);
    });
  });

  group('PillSwitch', () {
    testWidgets('the selected segment is panel with accent text; taps report the index', (tester) async {
      int? picked;
      await pumpUi(
        tester,
        PillSwitch(
          options: const [(TablerIcons.list, 'Listă'), (TablerIcons.map, 'Hartă')],
          selected: 0,
          onSelected: (i) => picked = i,
        ),
      );
      expect(tester.widget<Text>(find.text('Listă')).style?.color, AppColors.light.accent);
      expect(tester.widget<Text>(find.text('Hartă')).style?.color, AppColors.light.muted);
      await tester.tap(find.text('Hartă'));
      expect(picked, 1);
    });
  });

  group('RegisteredEventTile', () {
    testWidgets('date block 46 wide in navy, title, subtitle and the green badge', (tester) async {
      var taps = 0;
      await pumpUi(tester, _tile(onTap: () => taps++));
      expect(find.text('14'), findsOneWidget);
      expect(find.text('nov'), findsOneWidget);
      expect(find.text('Vulpile · peste 3 zile'), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('date-block'))).width, 46);
      expect(tester.widget<Text>(find.text('Înscriși')).style?.color, AppColors.light.success);
      await tester.tap(find.text('Moștenirea Cartografului'));
      expect(taps, 1);
    });
  });

  group('OpenEventCard', () {
    testWidgets('a 92 px strip with the badge and a 28 px share circle, then the title and route row', (tester) async {
      var taps = 0;
      var shares = 0;
      await pumpUi(tester, _card(onTap: () => taps++, onShare: () => shares++));
      expect(tester.getSize(find.byKey(const ValueKey('card-strip'))).height, 92);
      expect(tester.getSize(find.byKey(const ValueKey('card-share'))), const Size(28, 28));
      expect(find.text('Mai sunt 2 locuri'), findsOneWidget);
      expect(find.text('Sâm 21 nov'), findsOneWidget);
      expect(find.text('3,2 km · 1 h 30'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('card-share')));
      expect(shares, 1);
      await tester.tap(find.text('Protocolul Cerber'));
      expect(taps, 1);
    });

    testWidgets('no badge without one', (tester) async {
      await pumpUi(tester, _card(badge: null));
      expect(find.text('Mai sunt 2 locuri'), findsNothing);
    });
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('everything fits 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
      await pumpUi(
        tester,
        Column(children: [
          const SectionHeader(title: 'Deschise pentru înscriere', trailing: '4'),
          PillSwitch(options: const [(TablerIcons.list, 'Listă'), (TablerIcons.map, 'Hartă')], selected: 0, onSelected: (_) {}),
          _tile(),
          _card(),
        ]),
        width: 320,
        textScale: 1.3,
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
