import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/features/home/widgets/home_hero_ticker.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';

import '../../ui/pump_ui.dart';

final _start = DateTime(2026, 10, 20, 12);

Event _event() => Event(eventId: 'e1', name: 'Eveniment', dateEvent: _start, location: 'Sibiu');

HomeHeroActions _actions() => HomeHeroActions(
      onContinue: (e, t) {},
      onChat: (e, t) {},
      onEnterCode: (e) {},
      onDetails: (e) {},
      onShare: (e) {},
      onRegister: (e) {},
    );

void main() {
  testWidgets('shows the hero for the current time and counts down each second', (tester) async {
    var now = _start.subtract(const Duration(days: 3));
    final event = _event();

    await pumpUi(
      tester,
      HomeHeroTicker(
        now: () => now,
        resolve: (t) => UpcomingHero(event, _start.difference(t)),
        shown: UpcomingHero(event, _start.difference(now)),
        actions: _actions(),
        onLayoutChange: () {},
      ),
    );
    expect(find.text('Următorul tău joc'), findsOneWidget);
    expect(find.byType(ClockBuilder), findsOneWidget);
  });

  testWidgets('asks for a new page layout only when the kind of hero changes', (tester) async {
    var now = _start.subtract(const Duration(days: 3));
    var changes = 0;
    final event = _event();

    HomeHero resolve(DateTime t) =>
        t.isBefore(_start) ? UpcomingHero(event, _start.difference(t)) : StartingSoonHero(event, 50);

    await pumpUi(
      tester,
      HomeHeroTicker(
        now: () => now,
        resolve: resolve,
        shown: resolve(now),
        actions: _actions(),
        onLayoutChange: () => changes++,
      ),
    );

    // A second later: same kind, no layout change.
    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(changes, 0);

    // The event has started: a different kind of hero.
    now = _start.add(const Duration(minutes: 10));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(changes, greaterThan(0));
  });
}
