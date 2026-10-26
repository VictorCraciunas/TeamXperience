import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/create_event/start/create_event_start.dart';
import 'package:teamxperience/features/admin/create_event/start/create_event_start_sheet.dart';
import 'package:teamxperience/model/event.dart';

import '../../../ui/pump_ui.dart';

Event _event(String id, String name, {DateTime? date}) =>
    Event(eventId: id, name: name, location: 'Sibiu', dateEvent: date);

Future<void> _sheet(
  WidgetTester tester, {
  List<Event> drafts = const [],
  List<Event> oldEvents = const [],
  double scale = 1,
}) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  return pumpUi(
    tester,
    CreateEventStartSheet(drafts: drafts, oldEvents: oldEvents),
    textScale: scale,
  );
}

void main() {
  group('CreateEventStart arguments', () {
    test('from scratch has no event', () {
      expect(const StartFromScratch().arguments, {'event': null});
    });

    test('from an old event is a copy of it', () {
      final event = _event('a', 'Vechi');
      expect(StartFromEvent(event).arguments, {'event': event, 'isBlueprint': true});
    });

    test('a draft is resumed as a draft', () {
      final event = _event('a', 'Ciornă');
      expect(StartFromDraft(event).arguments, {'event': event, 'isDraft': true});
    });
  });

  group('start sheet', () {
    testWidgets('offers starting from scratch and from an old event', (tester) async {
      await _sheet(tester, oldEvents: [_event('a', 'Vechi')]);
      expect(find.text('Eveniment nou'), findsOneWidget);
      expect(find.text('De la zero'), findsOneWidget);
      expect(find.text('Dintr-un eveniment vechi'), findsOneWidget);
    });

    testWidgets('without drafts there is no Ciorne section', (tester) async {
      await _sheet(tester);
      expect(find.text('Ciorne'), findsNothing);
    });

    testWidgets('drafts are listed underneath', (tester) async {
      await _sheet(tester, drafts: [_event('d1', 'Sibiu Hunt'), _event('d2', 'Brașov')]);
      expect(find.text('Ciorne'), findsOneWidget);
      expect(find.text('Sibiu Hunt'), findsOneWidget);
      expect(find.text('Brașov'), findsOneWidget);
    });

    testWidgets('without old events that option says so and cannot be used', (tester) async {
      await _sheet(tester);
      expect(find.text('Nu ai evenimente vechi'), findsOneWidget);
      await tester.tap(find.text('Dintr-un eveniment vechi'));
      await tester.pumpAndSettle();
      expect(find.text('Alege un eveniment'), findsNothing);
    });

    testWidgets('does not overflow at a large text size', (tester) async {
      await _sheet(
        tester,
        drafts: [_event('d1', 'Un nume de eveniment foarte lung')],
        oldEvents: [_event('a', 'Vechi')],
        scale: 1.6,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('what the sheet returns', () {
    Future<CreateEventStart?> choose(
      WidgetTester tester,
      Future<void> Function() act, {
      List<Event> drafts = const [],
      List<Event> oldEvents = const [],
    }) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      CreateEventStart? result;
      await pumpUi(
        tester,
        Builder(
          builder:
              (context) => TextButton(
                onPressed: () async => result = await showCreateEventStartSheet(context, drafts: drafts, oldEvents: oldEvents),
                child: const Text('open'),
              ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await act();
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('De la zero', (tester) async {
      final result = await choose(tester, () => tester.tap(find.text('De la zero')));
      expect(result, isA<StartFromScratch>());
    });

    testWidgets('a draft', (tester) async {
      final draft = _event('d1', 'Sibiu Hunt');
      final result = await choose(tester, () => tester.tap(find.text('Sibiu Hunt')), drafts: [draft]);
      expect(result, isA<StartFromDraft>());
      expect((result as StartFromDraft).event.eventId, 'd1');
    });

    testWidgets('an old event, picked from the list newest first', (tester) async {
      final older = _event('o1', 'Anul trecut', date: DateTime(2025, 5, 1));
      final newer = _event('o2', 'Luna trecută', date: DateTime(2026, 9, 1));
      final result = await choose(
        tester,
        () async {
          await tester.tap(find.text('Dintr-un eveniment vechi'));
          await tester.pumpAndSettle();
          expect(find.text('Alege un eveniment'), findsOneWidget);
          expect(
            tester.getTopLeft(find.text('Luna trecută')).dy,
            lessThan(tester.getTopLeft(find.text('Anul trecut')).dy),
          );
          await tester.tap(find.text('Anul trecut'));
        },
        oldEvents: [older, newer],
      );
      expect(result, isA<StartFromEvent>());
      expect((result as StartFromEvent).event.eventId, 'o1');
    });

    testWidgets('closing the sheet returns nothing', (tester) async {
      final result = await choose(tester, () => tester.tapAt(const Offset(10, 10)));
      expect(result, isNull);
    });
  });
}
