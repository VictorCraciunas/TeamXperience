import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:teamxperience/features/events_tab/logic/map_points.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/registered_event_tile.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'event_map_pin.dart';
import 'events_here_list.dart';

/// The Hartă mode of the Evenimente tab: the start pins of the filtered
/// events, one pin per spot with a count when several share it; tapping one
/// shows its card, or the list of its events, at the bottom. Not drawn in the mockups,
/// so it follows the admin map's tiles and the list's tile style.
class EventsMap extends StatefulWidget {
  const EventsMap({
    super.key,
    required this.events,
    required this.registeredIds,
    required this.onOpen,
    this.showTiles = true,
  });

  final List<Event> events;
  final Set<String> registeredIds;
  final void Function(Event) onOpen;

  /// False in tests, which load no network tiles.
  final bool showTiles;

  @override
  State<EventsMap> createState() => _EventsMapState();
}

class _EventsMapState extends State<EventsMap> {
  List<Event>? _selected;

  @override
  Widget build(BuildContext context) {
    final points = mapPoints(widget.events);
    final groups = groupMapPoints(points);
    final bounds = pointsBounds([for (final p in points) p.$2]);
    if (bounds == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Niciun eveniment nu are încă locul pe hartă.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.45, color: context.colors.muted),
          ),
        ),
      );
    }

    final selected = _selected;
    // Pins that all share one spot give a zero-size box, which a camera fit
    // would zoom into forever, so they are centred like a single pin.
    final single = bounds.southWest == bounds.northEast;
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: points.first.$2,
            initialZoom: 15,
            initialCameraFit: single
                ? null
                : CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40), maxZoom: 16),
            onTap: (_, _) => setState(() => _selected = null),
          ),
          children: [
            if (widget.showTiles)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_map_test',
              ),
            MarkerLayer(
              markers: [
                for (final group in groups)
                  Marker(
                    point: group.at,
                    width: 32,
                    height: 32,
                    child: EventMapPin(
                      key: ValueKey('pin-${group.events.first.eventId}'),
                      count: group.events.length,
                      registered: group.events.any((e) => widget.registeredIds.contains(e.eventId)),
                      onTap: () => setState(() => _selected = group.events),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (selected != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: selected.length == 1 ? _card(selected.first) : EventsHereList(count: selected.length, children: [for (final e in selected) _card(e)]),
          ),
      ],
    );
  }

  Widget _card(Event e) {
    final date = e.dateEvent;
    return RegisteredEventTile(
      day: date == null ? '–' : '${date.day}',
      month: date == null ? '' : shortMonth(date.month),
      title: e.name ?? '',
      subtitle: [e.location ?? '', if (date != null) eventDayLine(date, e.arriveMinutesBefore)].where((s) => s.isNotEmpty).join(' · '),
      badge: widget.registeredIds.contains(e.eventId) ? 'Înscriși' : 'Deschis',
      onTap: () => widget.onOpen(e),
    );
  }
}
