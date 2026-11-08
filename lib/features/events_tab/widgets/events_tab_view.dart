import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/features/events_tab/logic/event_filters.dart';
import 'package:teamxperience/model/event.dart';

import 'events_header.dart';
import 'events_list.dart';
import 'events_search_field.dart';
import 'filter_chips_row.dart';

/// The Evenimente tab of mockup 03, built from plain values: the header, the
/// optional search field, the chips, then the list or the [map].
class EventsTabView extends StatelessWidget {
  const EventsTabView({
    super.key,
    required this.sections,
    required this.query,
    required this.mapMode,
    required this.searching,
    required this.teamNames,
    required this.teamCounts,
    required this.now,
    required this.onToggle,
    required this.onAll,
    required this.onSearch,
    required this.onToggleSearch,
    required this.onMode,
    required this.onOpen,
    required this.onShare,
    required this.onRefresh,
    required this.map,
    this.failed = false,
    this.loading = false,
  });

  final ({List<Event> registered, List<Event> open, List<Event> soon}) sections;
  final EventQuery query;
  final bool mapMode;

  /// The events could not be read and there are none from before.
  final bool failed;

  /// The first read is running.
  final bool loading;
  final bool searching;
  final Map<String, String> teamNames;
  final Map<String, int> teamCounts;
  final DateTime now;
  final void Function(EventFilter) onToggle;
  final VoidCallback onAll;
  final ValueChanged<String> onSearch;
  final VoidCallback onToggleSearch;
  final ValueChanged<bool> onMode;
  final void Function(Event) onOpen;
  final void Function(Event) onShare;
  final Future<void> Function() onRefresh;

  /// What the Hartă mode shows.
  final Widget map;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EventsHeader(mapMode: mapMode, onMode: onMode, onToggleSearch: onToggleSearch),
        if (searching) EventsSearchField(initial: query.search, onChanged: onSearch),
        FilterChipsRow(query: query, onToggle: onToggle, onAll: onAll),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : failed
              ? LoadFailed(message: 'Nu am putut încărca evenimentele.', onRetry: onRefresh)
              : mapMode
              ? Padding(padding: const EdgeInsets.only(top: 10), child: map)
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      EventsList(
                        sections: sections,
                        teamNames: teamNames,
                        teamCounts: teamCounts,
                        now: now,
                        onOpen: onOpen,
                        onShare: onShare,
                        onAll: onAll,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
