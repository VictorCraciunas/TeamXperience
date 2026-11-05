import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/model/event.dart';

/// The events that can go on the map, with their start pin.
List<(Event, LatLng)> mapPoints(List<Event> events) => [
      for (final e in events)
        if ((e.startLatitude, e.startLongitude) case (final lat?, final lng?)) (e, LatLng(lat, lng)),
    ];

/// The box around [points], or null without any.
LatLngBounds? pointsBounds(List<LatLng> points) => points.isEmpty ? null : LatLngBounds.fromPoints(points);
