import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/event/registered_event_card.dart';

import '../pump_ui.dart';

Event _event() => Event(
      eventId: 'e1',
      name: 'Xtreme Highschool Challenge 2026',
      location: 'Sibiu, zona centrală',
      dateEvent: DateTime(2026, 10, 22, 14),
    );

AppButton _button(WidgetTester tester) =>
    tester.widget<AppButton>(find.byType(AppButton));

void main() {
  testWidgets('a registration card shows a solid primary details button',
      (tester) async {
    await pumpUi(
      tester,
      RegisteredEventCard(event: _event(), onEventTap: (_) {}),
    );
    final button = _button(tester);
    expect(button.label, 'Detalii înscriere');
    expect(button.variant, AppButtonVariant.primary);
    expect(button.backgroundColor, isNull);
  });

  testWidgets('the upcoming card shows a white start button on the navy card',
      (tester) async {
    await pumpUi(
      tester,
      RegisteredEventCard(
        event: _event(),
        onEventTap: (_) {},
        upComingRegisteredEvent: true,
      ),
    );
    final button = _button(tester);
    expect(button.label, 'Începe jocul');
    expect(button.backgroundColor, Colors.white);
  });

  testWidgets('tapping the button reports the event', (tester) async {
    Event? tapped;
    await pumpUi(
      tester,
      RegisteredEventCard(event: _event(), onEventTap: (e) => tapped = e),
    );
    await tester.tap(find.byType(AppButton));
    expect(tapped?.eventId, 'e1');
  });
}
