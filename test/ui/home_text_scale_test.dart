import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/features/admin/home/logic/admin_hero.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_quick_actions_panel.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_stats_panel.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_upcoming_panel.dart';
import 'package:teamxperience/features/home/logic/preparation_steps.dart';
import 'package:teamxperience/features/home/widgets/events_panel.dart';
import 'package:teamxperience/features/home/widgets/how_it_works_panel.dart';
import 'package:teamxperience/features/home/widgets/preparation_panel.dart';
import 'package:teamxperience/features/home/widgets/registrations_panel.dart';
import 'package:teamxperience/model/event.dart';

import 'pump_ui.dart';

final _event = Event(
  eventId: 'e1',
  name: 'Un eveniment cu un nume foarte lung care trebuie să se încadreze',
  location: 'Piața Mare, Sibiu, zona centrală',
  dateEvent: DateTime(2026, 10, 22, 14),
);

void main() {
  final panels = <String, Widget>{
    'how it works': const HowItWorksPanel(),
    'preparation': const PreparationPanel(
      steps: [
        PreparationStep(title: 'Înscriere confirmată', subtitle: 'Vulturii de la Sibiu · 4 membri', done: true),
        PreparationStep(title: 'Codul de start', subtitle: 'Îl primești în ziua evenimentului', done: false),
      ],
    ),
    'registrations': RegistrationsPanel(events: [_event], onTap: (_) {}, onSeeAll: () {}),
    'events': EventsPanel(events: [_event], onTap: (_) {}, onSeeAll: () {}),
    'admin stats (live)': AdminStatsPanel(
      hero: AdminLiveHero(_event),
      stats: const AdminEventStats(teams: 128, persons: 512, finished: 64),
    ),
    'admin quick actions': AdminQuickActionsPanel(onCreateEvent: () {}, onCreateNews: () {}, onNotify: () {}),
    'admin upcoming': AdminUpcomingPanel(
      events: [_event],
      statsFor: (_) => const AdminEventStats(teams: 12, persons: 40),
      onTap: (_) {},
    ),
  };

  for (final entry in panels.entries) {
    testWidgets('${entry.key} fits a narrow screen at text scale 1.5', (tester) async {
      await pumpUi(tester, entry.value, textScale: 1.5, width: 320);
      expect(tester.takeException(), isNull);
    });
  }
}
