import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_upcoming_panel.dart';
import 'package:teamxperience/model/event.dart';

import '../../../ui/pump_ui.dart';

Event _event(String id) => Event(
      eventId: id,
      name: 'Eveniment $id',
      location: 'Sibiu',
      dateEvent: DateTime(2026, 10, 25, 14),
    );

AdminUpcomingPanel _panel(List<Event> events, {void Function(Event)? onTap}) {
  return AdminUpcomingPanel(
    events: events,
    statsFor: (_) => const AdminEventStats(teams: 12, persons: 40),
    onTap: onTap ?? (_) {},
  );
}

void main() {
  testWidgets('shows the whole title and the number of events', (tester) async {
    await pumpUi(tester, _panel([_event('a'), _event('b'), _event('c')]));
    expect(find.text('Evenimente viitoare'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('has no Vezi toate link', (tester) async {
    await pumpUi(tester, _panel([_event('a')]));
    expect(find.textContaining('Vezi toate'), findsNothing);
  });

  testWidgets('the title is never cut off with dots, it wraps instead', (tester) async {
    // A narrow card: the title does not fit on one line.
    await pumpUi(tester, _panel([_event('a')]), width: 260);
    expect(tester.takeException(), isNull);
    final paragraph = tester.renderObject<RenderParagraph>(find.text('Evenimente viitoare'));
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(find.text('Evenimente viitoare'), findsOneWidget);
  });

  testWidgets('tapping an event reports it', (tester) async {
    Event? tapped;
    await pumpUi(tester, _panel([_event('a')], onTap: (e) => tapped = e));
    await tester.tap(find.text('Eveniment a'));
    expect(tapped?.eventId, 'a');
  });

  testWidgets('with no events it shows an empty message and a zero count', (tester) async {
    await pumpUi(tester, _panel(const []));
    expect(find.text('Evenimente viitoare'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Nu ai evenimente programate.'), findsOneWidget);
  });
}
