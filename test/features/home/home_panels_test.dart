import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/preparation_steps.dart';
import 'package:teamxperience/features/home/widgets/events_panel.dart';
import 'package:teamxperience/features/home/widgets/how_it_works_panel.dart';
import 'package:teamxperience/features/home/widgets/preparation_panel.dart';
import 'package:teamxperience/features/home/widgets/registrations_panel.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/poster_card.dart';

import '../../ui/pump_ui.dart';

Event _event(String id, {int day = 22, int month = 10}) => Event(
      eventId: id,
      name: 'Eveniment $id',
      location: 'Sibiu',
      dateEvent: DateTime(2026, month, day, 14),
    );

void main() {
  testWidgets('how it works shows the three steps', (tester) async {
    await pumpUi(tester, const HowItWorksPanel());
    expect(find.text('Cum funcționează'), findsOneWidget);
    expect(find.text('Înscrie'), findsOneWidget);
    expect(find.text('Primești'), findsOneWidget);
    expect(find.text('Rezolvă'), findsOneWidget);
  });

  testWidgets('preparation shows each step and how many are done', (tester) async {
    await pumpUi(
      tester,
      const PreparationPanel(
        steps: [
          PreparationStep(title: 'Înscriere confirmată', subtitle: 'Vulturii · 4 membri', done: true),
          PreparationStep(title: 'Detalii echipă complete', subtitle: 'Căpitan', done: true),
          PreparationStep(title: 'Codul de start', subtitle: 'În ziua evenimentului', done: false),
        ],
      ),
    );
    expect(find.text('Pregătirea echipei'), findsOneWidget);
    expect(find.text('2 din 3'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNWidgets(2));
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  group('registrations', () {
    testWidgets('lists registered events and reports taps and see all', (tester) async {
      Event? tapped;
      var seeAll = 0;
      await pumpUi(
        tester,
        RegistrationsPanel(
          events: [_event('a'), _event('b', day: 2, month: 12)],
          onTap: (e) => tapped = e,
          onSeeAll: () => seeAll++,
        ),
      );
      expect(find.text('Înscrierile tale'), findsOneWidget);
      expect(find.text('Eveniment a'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      await tester.tap(find.text('Eveniment b'));
      expect(tapped?.eventId, 'b');
      await tester.tap(find.textContaining('Vezi toate'));
      expect(seeAll, 1);
    });

    testWidgets('renders nothing without registrations', (tester) async {
      await pumpUi(
        tester,
        RegistrationsPanel(events: const [], onTap: (_) {}, onSeeAll: () {}),
      );
      expect(find.text('Înscrierile tale'), findsNothing);
    });
  });

  group('events panel', () {
    testWidgets('shows a poster per event and reports taps', (tester) async {
      Event? tapped;
      await pumpUi(
        tester,
        EventsPanel(
          events: [_event('a'), _event('b')],
          onTap: (e) => tapped = e,
          onSeeAll: () {},
        ),
      );
      expect(find.byType(PosterCard), findsNWidgets(2));
      await tester.tap(find.byType(PosterCard).first);
      expect(tapped?.eventId, 'a');
    });

    testWidgets('shows an empty message when there are no events', (tester) async {
      await pumpUi(
        tester,
        EventsPanel(events: const [], onTap: (_) {}, onSeeAll: () {}),
      );
      expect(find.text('Nu sunt evenimente programate momentan.'), findsOneWidget);
    });

    testWidgets('an event without an image does not break the poster', (tester) async {
      await pumpUi(
        tester,
        EventsPanel(events: [_event('a')], onTap: (_) {}, onSeeAll: () {}),
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
