import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/route_preview.dart';
import 'route_end_pin.dart';

/// The small map at the top of the logistics card. It is only for looking at:
/// a drag here scrolls the page.
class EventRouteMap extends StatelessWidget {
  const EventRouteMap({super.key, required this.route, this.showTiles = true});

  static const double _pinSize = 16;

  final RoutePreview route;

  /// Off in tests, which have no network.
  final bool showTiles;

  Marker _pin(LatLng point, Color color) => Marker(
        point: point,
        width: _pinSize,
        height: _pinSize,
        child: RouteEndPin(color: color),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: route.start,
              initialCameraFit: CameraFit.coordinates(
                coordinates: route.line,
                padding: const EdgeInsets.all(28),
                maxZoom: 17,
              ),
              backgroundColor: colors.inset,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              if (showTiles)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'ro.teamxperience.teamxperience',
                ),
              PolylineLayer(polylines: [
                Polyline(
                  points: route.line,
                  strokeWidth: 2.5,
                  color: colors.tick,
                  pattern: StrokePattern.dashed(segments: const [6, 5]),
                ),
              ]),
              MarkerLayer(markers: [
                _pin(route.start, colors.accent),
                _pin(route.finish, colors.navy),
              ]),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ColoredBox(
              color: colors.panel.withValues(alpha: .8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Text('© OpenStreetMap', style: TextStyle(fontSize: 12, color: colors.muted)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
