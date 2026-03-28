import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;

  const RouteResult({required this.points, required this.distanceMeters});
}

class RouteService {
  RouteService._();
  static final RouteService _instance = RouteService._();
  factory RouteService() => _instance;

  DateTime? _lastRequestTime;
  static const int _throttleSeconds = 5;

  Future<RouteResult?> fetchWalkingRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    // Throttle: only request once every 5 seconds
    final now = DateTime.now();
    if (_lastRequestTime != null &&
        now.difference(_lastRequestTime!).inSeconds < _throttleSeconds) {
      return null;
    }
    _lastRequestTime = now;

    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/foot/'
        '${from.longitude},${from.latitude};'
        '${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson&continue_straight=true',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coords = geometry['coordinates'] as List;
          final routeDistance = (routes[0]['distance'] as num).toDouble();

          final points = coords
              .map<LatLng>((c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ))
              .toList();

          return RouteResult(points: points, distanceMeters: routeDistance);
        }
      }
    } catch (_) {
      // If routing fails, return null so caller can fallback
    }

    return null;
  }

  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }
}
