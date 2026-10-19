import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/features/admin/home/logic/admin_hero.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_hero_actions.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_hero_section.dart';
import 'package:teamxperience/model/event.dart';

import '../../../ui/pump_ui.dart';

final _now = DateTime(2026, 10, 20, 12);

Event _event({String name = 'Treasure Hunt Sibiu', Duration fromNow = const Duration(minutes: -45)}) =>
    Event(eventId: 'e1', name: name, dateEvent: _now.add(fromNow));

final _log = <String>[];

AdminHeroActions get _actions => AdminHeroActions(
      onManage: (e) => _log.add('manage'),
      onMap: (e) => _log.add('map'),
      onChats: (e) => _log.add('chats'),
      onTeams: (e) => _log.add('teams'),
      onNotify: (e) => _log.add('notify'),
    );

Future<void> _pump(
  WidgetTester tester,
  AdminHero hero, {
  AdminEventStats stats = const AdminEventStats(),
  double scale = 1,
}) {
  _log.clear();
  return pumpUi(
    tester,
    AdminHeroSection(hero: hero, now: _now, stats: stats, actions: _actions),
    textScale: scale,
  );
}

void main() {
  testWidgets('live shows the pill, the stats line and fires its actions', (tester) async {
    await _pump(
      tester,
      AdminLiveHero(_event()),
      stats: const AdminEventStats(teams: 12, persons: 40, finished: 3, inPlay: 8),
    );
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('2:15:00 rămase'), findsOneWidget);
    expect(find.text('12 echipe · 3 au terminat · 8 în joc'), findsOneWidget);
    await tester.tap(find.text('Gestionează eveniment'));
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    expect(_log, ['manage', 'map', 'chats']);
  });

  testWidgets('starting soon shows the pill, the time chip and fires its actions', (tester) async {
    await _pump(
      tester,
      AdminSoonHero(_event(fromNow: const Duration(hours: 2, minutes: 5)), const Duration(hours: 2, minutes: 5)),
      stats: const AdminEventStats(teams: 5, persons: 17),
    );
    expect(find.text('Urmează'), findsOneWidget);
    expect(find.text('Începe în 2 h 5 min'), findsOneWidget);
    expect(find.text('5 echipe înscrise · 17 persoane'), findsOneWidget);
    await tester.tap(find.text('Vezi echipele înscrise'));
    await tester.tap(find.byIcon(Icons.notifications_none));
    expect(_log, ['teams', 'notify']);
  });

  testWidgets('zero teams renders zeros', (tester) async {
    await _pump(tester, AdminLiveHero(_event()));
    expect(find.text('0 echipe · 0 au terminat · 0 în joc'), findsOneWidget);
  });

  testWidgets('a long name and no image render without overflow at large text', (tester) async {
    await _pump(tester, AdminLiveHero(_event(name: 'A' * 60)), scale: 1.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no hero renders nothing', (tester) async {
    await _pump(tester, const NoAdminHero());
    expect(find.byType(Text), findsNothing);
  });
}
