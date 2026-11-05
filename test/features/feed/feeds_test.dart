import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_feed.dart';
import 'package:teamxperience/model/stire.dart';

import '../../ui/pump_ui.dart';

void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('NewsFeed', () {
    testWidgets('shows posts, tags private news and reports taps', (tester) async {
      _tall(tester);
      Stire? opened;
      await pumpUi(
        tester,
        SizedBox(
          height: 2400,
          child: NewsFeed(
            news: [
              Stire(id: '1', title: 'Prima', description: 'Text.', type: StireType.PRIVATA),
              Stire(id: '2', title: 'A doua', description: 'Alt text.', type: StireType.PUBLICA),
            ],
            onTap: (s) => opened = s,
            onShare: (_) {},
          ),
        ),
      );
      expect(find.text('Privată'), findsOneWidget);
      await tester.tap(find.text('A doua'));
      expect(opened?.id, '2');
    });

    testWidgets('shows the empty message', (tester) async {
      _tall(tester);
      await pumpUi(
        tester,
        SizedBox(height: 300, child: NewsFeed(news: const [], onTap: (_) {}, onShare: (_) {})),
      );
      expect(find.text('Nu există știri'), findsOneWidget);
    });
  });
  group('feed headers', () {
    testWidgets('the news header is part of the list and stays when empty', (tester) async {
      await pumpUi(
        tester,
        SizedBox(
          height: 500,
          child: NewsFeed(header: const Text('antet'), news: const [], onTap: (_) {}, onShare: (_) {}),
        ),
      );
      expect(find.text('antet'), findsOneWidget);
      expect(find.text('Nu există știri'), findsOneWidget);
    });
  });
}
