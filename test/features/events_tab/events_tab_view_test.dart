import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/events_tab/logic/event_filters.dart';
import 'package:teamxperience/features/events_tab/logic/event_sections.dart';
import 'package:teamxperience/features/events_tab/widgets/events_tab_view.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/ui.dart';

final _now = DateTime(2026, 11, 11, 12);

Future<void> _pump(
  WidgetTester tester, {
  EventQuery query = const EventQuery(),
  List<Event>? events,
  void Function(EventFilter)? onToggle,
  VoidCallback? onAll,
  ThemeData? theme,
  double width = 390,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final all = events ?? [sampleEvent(), ...sampleOpenEvents()];
  final sections = sectionEvents(applyQuery(all, query, _now), {'sample'}, _now);
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: Scaffold(
      body: EventsTabView(
        sections: sections,
        query: query,
        mapMode: false,
        searching: false,
        teamNames: const {'sample': 'Vulpile'},
        teamCounts: const {'cerber': 10},
        now: _now,
        onToggle: onToggle ?? (_) {},
        onAll: onAll ?? () {},
        onSearch: (_) {},
        onToggleSearch: () {},
        onMode: (_) {},
        onOpen: (_) {},
        onShare: (_) {},
        onRefresh: () async {},
        map: const SizedBox.shrink(),
      ),
    ),
  ));
}

void main() {
  testWidgets('shows the mockup copy', (tester) async {
    await _pump(tester);
    for (final text in [
      'Evenimente',
      'Listă',
      'Hartă',
      'Toate',
      'Luna asta',
      'Sub 2 h',
      'Înscrierile tale',
      'Moștenirea Cartografului',
      'Vulpile · peste 3 zile',
      'Înscriși',
      'Deschise pentru înscriere',
      '2',
      'Protocolul Cerber',
      'Mai sunt 2 locuri',
      'Sâm 21 nov',
      '3,2 km · 1 h 30',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
  });

  testWidgets('a chip toggles its filter and Toate clears them', (tester) async {
    EventFilter? toggled;
    var all = 0;
    await _pump(tester, onToggle: (f) => toggled = f, onAll: () => all++);
    await tester.tap(find.text('Luna asta'));
    expect(toggled, EventFilter.thisMonth);
    await tester.tap(find.text('Toate'));
    expect(all, 1);
  });

  testWidgets('when nothing matches it says so and offers to show everything', (tester) async {
    var all = 0;
    await _pump(tester, query: const EventQuery(search: 'nimic de gasit'), onAll: () => all++);
    expect(find.text('Niciun eveniment nu se potrivește.'), findsOneWidget);
    await tester.tap(find.text('Arată toate'));
    expect(all, 1);
  });

  testWidgets('the chips row scrolls and nothing overflows at 320 px and 1.3x, light and dark', (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await _pump(tester, width: 320, textScale: 1.3, theme: theme);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('filter-chips')), findsOneWidget);
    }
  });
}
