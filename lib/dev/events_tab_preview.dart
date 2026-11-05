import 'package:flutter/material.dart';
import 'package:teamxperience/features/events_tab/logic/event_filters.dart';
import 'package:teamxperience/features/events_tab/logic/event_sections.dart';
import 'package:teamxperience/features/events_tab/widgets/events_map.dart';
import 'package:teamxperience/features/events_tab/widgets/events_tab_view.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/navigation/app_bottom_nav.dart';

import 'sample_event.dart';

/// The Evenimente tab of mockup 03 with its events, inside the five-tab bar;
/// the app bar's switch shows the bar's "În joc" state.
class EventsTabPreview extends StatefulWidget {
  const EventsTabPreview({super.key, this.showTiles = true});

  /// False in tests, which load no map tiles.
  final bool showTiles;

  @override
  State<EventsTabPreview> createState() => _EventsTabPreviewState();
}

class _EventsTabPreviewState extends State<EventsTabPreview> {
  static final _now = DateTime(2026, 11, 11, 12);
  final List<Event> _events = [sampleEvent(), ...sampleOpenEvents()];
  EventQuery _query = const EventQuery();
  bool _map = false;
  bool _searching = false;
  bool _live = false;

  void _say(String what) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(what)));

  void _toggle(EventFilter f) {
    final next = {..._query.filters};
    if (!next.remove(f)) next.add(f);
    setState(() => _query = EventQuery(filters: next, search: _query.search));
  }

  @override
  Widget build(BuildContext context) {
    final sections = sectionEvents(applyQuery(_events, _query, _now), {'sample'}, _now);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evenimente'),
        actions: [
          const Center(child: Text('În joc')),
          Switch(value: _live, onChanged: (v) => setState(() => _live = v)),
        ],
      ),
      body: EventsTabView(
        sections: sections,
        query: _query,
        mapMode: _map,
        searching: _searching,
        teamNames: const {'sample': 'Vulpile'},
        teamCounts: const {'cerber': 10},
        now: _now,
        onToggle: _toggle,
        onAll: () => setState(() {
          _query = const EventQuery();
          _searching = false;
        }),
        onSearch: (s) => setState(() => _query = EventQuery(filters: _query.filters, search: s)),
        onToggleSearch: () => setState(() => _searching = !_searching),
        onMode: (m) => setState(() => _map = m),
        onOpen: (e) => _say('open ${e.name}'),
        onShare: (e) => _say('share ${e.name}'),
        onRefresh: () async {},
        map: EventsMap(
          events: [...sections.registered, ...sections.open, ...sections.soon],
          registeredIds: const {'sample'},
          onOpen: (e) => _say('open ${e.name}'),
          showTiles: widget.showTiles,
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: PlayerTab.events,
        onSelected: (i) => _say('tab $i'),
        items: playerNavItems(live: _live),
      ),
    );
  }
}
