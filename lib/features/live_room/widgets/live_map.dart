import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/live_map_points.dart';
import '../logic/live_status.dart';
import '../logic/live_texts.dart';
import 'team_pin.dart';

/// The teams on the map, over the event's route. The small map in the room
/// follows the teams by itself and takes no gestures but a tap on a pin; the
/// big one ([interactive]) is the organiser's to move.
class LiveMap extends StatefulWidget {
  const LiveMap({
    super.key,
    required this.event,
    required this.teams,
    required this.now,
    required this.onTeam,
    this.onBigMap,
    this.interactive = false,
  });

  /// Where the map opens when nothing has a position yet: Sibiu.
  static const fallbackCentre = LatLng(45.7983, 24.1256);

  final Event event;
  final List<Team> teams;
  final DateTime now;
  final ValueChanged<Team> onTeam;

  /// Shows the "Hartă mare" pill.
  final VoidCallback? onBigMap;
  final bool interactive;

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  final MapController _controller = MapController();
  bool _ready = false;

  List<LatLng> _points(LiveMap map) => [
        ...routePoints(map.event),
        for (final team in map.teams)
          if (hasPin(team)) LatLng(team.latitude, team.longitude),
      ];

  CameraFit _fit(List<LatLng> points) => CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.all(28),
        maxZoom: 16,
      );

  @override
  void didUpdateWidget(LiveMap old) {
    super.didUpdateWidget(old);
    if (widget.interactive || !_ready) return;
    final points = _points(widget);
    if (points.isEmpty) return;
    if (_samePoints(points, _points(old))) return;
    _controller.fitCamera(_fit(points));
  }

  bool _samePoints(List<LatLng> a, List<LatLng> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final route = routePoints(widget.event);
    final points = _points(widget);
    final over = eventEnded(widget.event, widget.now);
    final bigMap = widget.onBigMap;
    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: LiveMap.fallbackCentre,
            initialZoom: 13,
            initialCameraFit: points.isEmpty ? null : _fit(points),
            maxZoom: 18,
            minZoom: 5,
            backgroundColor: colors.inset,
            interactionOptions: InteractionOptions(
              flags: widget.interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
            ),
            onMapReady: () => _ready = true,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.teamxperience.app',
            ),
            if (route.length > 1)
              PolylineLayer(polylines: [
                Polyline(
                  points: route,
                  strokeWidth: 2.5,
                  color: colors.tick,
                  pattern: StrokePattern.dashed(segments: const [6, 5]),
                ),
              ]),
            MarkerLayer(markers: [
              for (final team in widget.teams)
                if (hasPin(team))
                  Marker(
                    point: LatLng(team.latitude, team.longitude),
                    width: widget.interactive ? 36 : 28,
                    height: widget.interactive ? 36 : 28,
                    child: Center(
                      child: TeamPin(
                        key: ValueKey('pin-${team.name}'),
                        initial: teamInitial(team.name),
                        size: widget.interactive ? 32 : 24,
                        tone: pinToneOf(
                          team,
                          missionCount: widget.event.missions.length,
                          now: widget.now,
                          eventOver: over,
                        ),
                        onTap: () => widget.onTeam(team),
                      ),
                    ),
                  ),
            ]),
          ],
        ),
        if (bigMap != null)
          Positioned(
            right: 8,
            bottom: 8,
            child: AppChip(label: 'Hartă mare', icon: TablerIcons.maximize, onTap: bigMap),
          ),
      ],
    );
  }
}
