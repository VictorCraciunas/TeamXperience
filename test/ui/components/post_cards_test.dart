import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/event/event_post_card.dart';
import 'package:teamxperience/ui/components/misc/choice_chips_row.dart';
import 'package:teamxperience/ui/components/news/news_post_card.dart';

import '../pump_ui.dart';

void main() {
  group('EventPostCard', () {
    Widget card({String? tag, bool dimmed = false, VoidCallback? onTap, VoidCallback? onShare, String title = 'Xtreme Challenge'}) {
      return EventPostCard(
        title: title,
        dateLabel: '25 OCT',
        place: 'Sibiu, zona centrală',
        details: 'Sâmbătă · ora 14:00 · 12 echipe',
        tag: tag,
        dimmed: dimmed,
        onTap: onTap ?? () {},
        onShare: onShare ?? () {},
      );
    }

    testWidgets('shows the date, title, place and details', (tester) async {
      await pumpUi(tester, card());
      expect(find.text('25 OCT'), findsOneWidget);
      expect(find.text('Xtreme Challenge'), findsOneWidget);
      expect(find.text('Sibiu, zona centrală'), findsOneWidget);
      expect(find.text('Sâmbătă · ora 14:00 · 12 echipe'), findsOneWidget);
    });

    testWidgets('tapping the post and the share icon report separately', (tester) async {
      final log = <String>[];
      await pumpUi(tester, card(onTap: () => log.add('open'), onShare: () => log.add('share')));
      await tester.tap(find.text('Xtreme Challenge'));
      await tester.tap(find.byIcon(Icons.share_outlined));
      expect(log, ['open', 'share']);
    });

    testWidgets('shows a tag when given and fades when dimmed', (tester) async {
      await pumpUi(tester, card(tag: 'Înscris', dimmed: true));
      expect(find.text('Înscris'), findsOneWidget);
      final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('a long title and no image fit at large text', (tester) async {
      await pumpUi(tester, card(title: 'T' * 80), textScale: 1.5, width: 320);
      expect(tester.takeException(), isNull);
    });
  });

  group('NewsPostCard', () {
    testWidgets('shows category, date, title and preview and reports taps', (tester) async {
      final log = <String>[];
      await pumpUi(
        tester,
        NewsPostCard(
          title: 'Rezultatele ediției',
          preview: 'Echipa Vulturii a câștigat.',
          categoryLabel: 'Anunț',
          dateLabel: '20 oct 2026',
          onTap: () => log.add('open'),
          onShare: () => log.add('share'),
        ),
      );
      expect(find.text('Anunț'), findsOneWidget);
      expect(find.text('20 oct 2026'), findsOneWidget);
      expect(find.text('Rezultatele ediției'), findsOneWidget);
      expect(find.text('Echipa Vulturii a câștigat.'), findsOneWidget);
      await tester.tap(find.text('Rezultatele ediției'));
      await tester.tap(find.byIcon(Icons.share_outlined));
      expect(log, ['open', 'share']);
    });

    testWidgets('a long preview and no image fit at large text', (tester) async {
      await pumpUi(
        tester,
        NewsPostCard(
          title: 'T' * 80,
          preview: 'P' * 400,
          categoryLabel: 'Anunț',
          dateLabel: '20 oct',
          onTap: () {},
          onShare: () {},
        ),
        textScale: 1.5,
        width: 320,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('ChoiceChipsRow', () {
    testWidgets('marks the selected chip and reports taps', (tester) async {
      int? picked;
      await pumpUi(
        tester,
        ChoiceChipsRow(labels: const ['Toate', 'Înscrise'], selectedIndex: 0, onSelected: (i) => picked = i),
      );
      await tester.tap(find.text('Înscrise'));
      expect(picked, 1);
    });
  });
}
