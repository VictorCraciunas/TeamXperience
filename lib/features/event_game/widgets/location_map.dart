import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/ui/components/game/round_icon_button.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The map of a location puzzle (mockup 07): the circle the team must enter,
/// a flag at its centre, the walking route dashed, the player's dot, and a
/// button that fits both on screen.
class LocationMap extends StatelessWidget {
  const LocationMap({
    super.key,
    required this.controller,
    required this.target,
    required this.radius,
    this.player,
    this.route = const [],
    required this.onRecenter,
  });

  final MapController controller;
  final LatLng target;
  final int radius;
  final LatLng? player;
  final List<LatLng> route;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final me = player;
    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(initialCenter: target, initialZoom: 17, maxZoom: 19, minZoom: 10),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.teamxperience.app',
            ),
            CircleLayer(circles: [
              CircleMarker(
                point: target,
                radius: radius.toDouble(),
                useRadiusInMeter: true,
                color: palette.accent.withValues(alpha: .12),
                borderColor: palette.accent,
                borderStrokeWidth: 2,
              ),
            ]),
            if (route.length > 1)
              PolylineLayer(polylines: [
                Polyline(
                  points: route,
                  strokeWidth: 2.5,
                  color: palette.accent,
                  pattern: StrokePattern.dashed(segments: const [6, 5]),
                ),
              ]),
            MarkerLayer(markers: [
              Marker(
                point: target,
                width: 24,
                height: 24,
                child: Icon(TablerIcons.flag, size: 17, color: palette.accent),
              ),
              if (me != null)
                Marker(
                  point: me,
                  width: 22,
                  height: 22,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.panel, width: 3),
                    ),
                  ),
                ),
            ]),
          ],
        ),
        Positioned(
          left: 0,
          top: 0,
          child: RoundIconButton(icon: TablerIcons.current_location, label: 'Arată-mă pe hartă', onTap: onRecenter),
        ),
      ],
    );
  }
}
