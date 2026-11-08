import 'package:latlong2/latlong.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/event_service/event_route.dart';

/// What the event page draws before the game: a pin at each end, and a line
/// that passes the missions without marking them.
class RoutePreview {
  const RoutePreview({required this.start, required this.finish, required this.line});

  final LatLng start;
  final LatLng finish;
  final List<LatLng> line;
}

/// The preview, or null until the event has both a start and a finish pin.
RoutePreview? routePreviewOf(Event event) {
  final startLat = event.startLatitude;
  final startLng = event.startLongitude;
  final finishLat = event.finishLatitude;
  final finishLng = event.finishLongitude;
  if (startLat == null || startLng == null || finishLat == null || finishLng == null) return null;
  return RoutePreview(
    start: LatLng(startLat, startLng),
    finish: LatLng(finishLat, finishLng),
    line: smoothLine(routePoints(event)),
  );
}
