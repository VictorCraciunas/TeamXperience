import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/features/events_dashboard/events_dashboard_user/widgets/events_feed.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_feed.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/stire.dart';

import '../../ui/pump_ui.dart';

Event _event(String id, int day) => Event(
      eventId: id,
      name: 'Eveniment $id',
      location: 'Sibiu',
      dateEvent: DateTime(2026, 10, day, 14),
    );

void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('EventsFeed', () {
    testWidgets('tags registered events and lists past events last', (tester) async {
      _tall(tester);
      await pumpUi(
        tester,
        SizedBox(
          height: 2400,
          child: EventsFeed(
            upcoming: [_event('a', 24), _event('b', 26)],
            past: [_event('old', 1)],
            registeredIds: const {'b'},
            onTap: (_) {},
            onShare: (_) {},
          ),
        ),
      );
      expect(find.text('Înscris'), findsOneWidget);
      expect(find.text('Eveniment a'), findsOneWidget);
      final a = tester.getTopLeft(find.text('Eveniment a')).dy;
      final old = tester.getTopLeft(find.text('Eveniment old')).dy;
      expect(old, greaterThan(a));
    });

    testWidgets('reports taps and shares for the right event', (tester) async {
      _tall(tester);
      final log = <String>[];
      await pumpUi(
        tester,
        SizedBox(
          height: 2400,
          child: EventsFeed(
            upcoming: [_event('a', 24)],
            registeredIds: const {},
            onTap: (e) => log.add('open:${e.eventId}'),
            onShare: (e) => log.add('share:${e.eventId}'),
          ),
        ),
      );
      await tester.tap(find.text('Eveniment a'));
      await tester.tap(find.byIcon(Icons.share_outlined));
      expect(log, ['open:a', 'share:a']);
    });

    testWidgets('shows the empty message', (tester) async {
      _tall(tester);
      await pumpUi(
        tester,
        SizedBox(
          height: 300,
          child: EventsFeed(
            upcoming: const [],
            registeredIds: const {},
            onTap: (_) {},
            onShare: (_) {},
            emptyMessage: 'Nimic',
          ),
        ),
      );
      expect(find.text('Nimic'), findsOneWidget);
    });
  });

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
    testWidgets('the events header is part of the list and scrolls away', (tester) async {
      await pumpUi(
        tester,
        SizedBox(
          height: 500,
          child: EventsFeed(
            header: const Text('antet'),
            upcoming: [for (var i = 1; i <= 6; i++) _event('e$i', 20 + i)],
            registeredIds: const {},
            onTap: (_) {},
            onShare: (_) {},
          ),
        ),
      );
      expect(find.text('antet'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pump();
      expect(find.text('antet'), findsNothing);
    });

    testWidgets('the header stays when there are no events', (tester) async {
      await pumpUi(
        tester,
        SizedBox(
          height: 500,
          child: EventsFeed(
            header: const Text('antet'),
            upcoming: const [],
            registeredIds: const {},
            onTap: (_) {},
            onShare: (_) {},
            emptyMessage: 'Nimic',
          ),
        ),
      );
      expect(find.text('antet'), findsOneWidget);
      expect(find.text('Nimic'), findsOneWidget);
    });

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
