import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/model/event.dart';

/// The events that can go on the map, with their start pin.
List<(Event, LatLng)> mapPoints(List<Event> events) => [
      for (final e in events)
        if ((e.startLatitude, e.startLongitude) case (final lat?, final lng?)) (e, LatLng(lat, lng)),
    ];

/// Events whose start pins are this close share one pin: a few games often
/// start at the same square, and stacked pins hide all but the top one.
const double sharedPinMeters = 25;

/// Events that share a spot on the map, at the first one's pin.
class MapGroup {
  const MapGroup(this.at, this.events);

  final LatLng at;
  final List<Event> events;
}

/// [points] gathered into one group per spot, in the order given.
List<MapGroup> groupMapPoints(List<(Event, LatLng)> points) {
  const distance = Distance();
  final groups = <(LatLng, List<Event>)>[];
  for (final (event, point) in points) {
    final near = groups.where((g) => distance.as(LengthUnit.Meter, g.$1, point) <= sharedPinMeters).firstOrNull;
    if (near == null) {
      groups.add((point, [event]));
    } else {
      near.$2.add(event);
    }
  }
  return [for (final (at, events) in groups) MapGroup(at, events)];
}

/// The box around [points], or null without any.
LatLngBounds? pointsBounds(List<LatLng> points) => points.isEmpty ? null : LatLngBounds.fromPoints(points);
