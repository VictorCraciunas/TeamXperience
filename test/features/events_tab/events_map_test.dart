import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/events_tab/widgets/event_map_pin.dart';
import 'package:teamxperience/features/events_tab/widgets/events_map.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/ui.dart';

Future<void> _pump(WidgetTester tester, List<Event> events, {void Function(Event)? onOpen}) async {
  tester.view.physicalSize = const Size(390 * 3, 700 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: EventsMap(
        events: events,
        registeredIds: const {'sample'},
        onOpen: onOpen ?? (_) {},
        showTiles: false,
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  testWidgets('without pins it says so instead of an empty map', (tester) async {
    await _pump(tester, [Event(eventId: 'x', name: 'Fără loc')]);
    expect(find.text('Niciun eveniment nu are încă locul pe hartă.'), findsOneWidget);
    expect(find.byType(EventMapPin), findsNothing);
  });

  testWidgets('a pin opens a card, and the card opens the event', (tester) async {
    Event? opened;
    await _pump(tester, [sampleEvent(), ...sampleOpenEvents()], onOpen: (e) => opened = e);
    expect(find.byType(EventMapPin), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('pin-cerber')));
    await tester.pump();
    expect(find.text('Protocolul Cerber'), findsOneWidget);
    expect(find.text('Deschis'), findsOneWidget);
    await tester.tap(find.text('Protocolul Cerber'));
    expect(opened?.eventId, 'cerber');
  });

  testWidgets('a registered event is marked on its card', (tester) async {
    await _pump(tester, [sampleEvent()]);
    await tester.tap(find.byKey(const ValueKey('pin-sample')));
    await tester.pump();
    expect(find.text('Înscriși'), findsOneWidget);
  });

  testWidgets('two events on the same start pin still open a map', (tester) async {
    final a = sampleEvent();
    final b = Event(
      eventId: 'twin',
      name: 'Geamăn',
      startLatitude: a.startLatitude,
      startLongitude: a.startLongitude,
    );
    Event? opened;
    await _pump(tester, [a, b], onOpen: (e) => opened = e);
    expect(tester.takeException(), isNull);
    // One pin that says how many are there, not two stacked on each other.
    expect(find.byType(EventMapPin), findsOneWidget);
    expect(find.descendant(of: find.byType(EventMapPin), matching: find.text('2')), findsOneWidget);

    await tester.tap(find.byType(EventMapPin));
    await tester.pump();
    expect(find.text('2 evenimente aici'), findsOneWidget);
    expect(find.text(a.name ?? ''), findsOneWidget);
    expect(find.text('Geamăn'), findsOneWidget);
    await tester.tap(find.text('Geamăn'));
    expect(opened?.eventId, 'twin');
  });

  testWidgets('many events on one spot: the list scrolls and fits', (tester) async {
    final a = sampleEvent();
    final many = [
      for (var i = 0; i < 8; i++)
        Event(eventId: 'e$i', name: 'Eveniment $i', startLatitude: a.startLatitude, startLongitude: a.startLongitude),
    ];
    await _pump(tester, many);
    await tester.tap(find.byType(EventMapPin));
    await tester.pump();
    expect(find.text('8 evenimente aici'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
