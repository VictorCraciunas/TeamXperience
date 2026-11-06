import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/features/event_game/logic/location_texts.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/service/LocationService.dart';
import 'package:teamxperience/service/route_service.dart';

import 'location_map.dart';
import 'location_puzzle_view.dart';

/// A location puzzle: follows the phone's position, measures the distance and
/// the way to the target, and lets the team in once inside the circle
/// ([Puzzle.radiusMeters]). Draws [LocationPuzzleView].
class GeolocationPuzzleWidget extends StatefulWidget {
  const GeolocationPuzzleWidget({
    super.key,
    required this.puzzle,
    required this.onSolved,
    required this.routeService,
    this.isMissionCompleted = false,
    this.onHint,
    this.onPicture = false,
  });

  final Puzzle puzzle;
  final VoidCallback onSolved;
  final RouteService routeService;
  final bool isMissionCompleted;
  final VoidCallback? onHint;
  final bool onPicture;

  @override
  State<GeolocationPuzzleWidget> createState() => _GeolocationPuzzleWidgetState();
}

class _GeolocationPuzzleWidgetState extends State<GeolocationPuzzleWidget> with WidgetsBindingObserver {
  final MapController _map = MapController();
  final LocationService _location = LocationService();
  StreamSubscription<Position>? _positions;

  LocationViewState _state = LocationViewState.waiting;
  LatLng? _player;
  double? _meters;
  double? _bearing;
  final List<double> _readings = [];
  List<LatLng> _route = const [];
  bool _fitted = false;

  LatLng? get _target {
    final point = locationTarget(widget.puzzle);
    return point == null ? null : LatLng(point.lat, point.lng);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isMissionCompleted) {
      _state = LocationViewState.done;
    } else if (_target == null) {
      _state = LocationViewState.noTarget;
    } else {
      _startTracking();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positions?.cancel();
    super.dispose();
  }

  /// Back from the settings: check again, without asking a second time (the
  /// permission dialog itself pauses and resumes the app).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final blocked = _state == LocationViewState.denied || _state == LocationViewState.serviceOff;
    if (state == AppLifecycleState.resumed && blocked) _startTracking(ask: false);
  }

  /// Location switched off, or permission refused, as a view state.
  Future<LocationAccess> _access({required bool ask}) async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();
    if (ask && serviceOn && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return locationAccess(serviceOn: serviceOn, permission: permission);
  }

  void _blocked(LocationAccess access) {
    if (!mounted) return;
    setState(() {
      _state = access == LocationAccess.serviceOff ? LocationViewState.serviceOff : LocationViewState.denied;
    });
  }

  /// The stream failed (location switched off mid-puzzle, or taken away).
  Future<void> _onStreamError() async {
    final access = await _access(ask: false);
    _blocked(access == LocationAccess.ok ? LocationAccess.denied : access);
  }

  Future<void> _startTracking({bool ask = true}) async {
    final target = _target;
    if (target == null) return;
    final access = await _access(ask: ask);
    if (!mounted) return;
    if (access != LocationAccess.ok) return _blocked(access);
    if (_state != LocationViewState.tracking) setState(() => _state = LocationViewState.waiting);

    await _positions?.cancel();
    if (!mounted) return;
    _positions = _location.getPositionStream(distanceFilter: 2).listen(
          (position) => _onFix(position, target),
          onError: (Object _) => _onStreamError(),
        );
    try {
      final first = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _onFix(first, target);
    } catch (_) {}
  }

  void _onFix(Position position, LatLng target) {
    if (!mounted) return;
    final player = LatLng(position.latitude, position.longitude);
    final meters = Geolocator.distanceBetween(position.latitude, position.longitude, target.latitude, target.longitude);
    final bearing = Geolocator.bearingBetween(position.latitude, position.longitude, target.latitude, target.longitude);
    setState(() {
      _state = LocationViewState.tracking;
      _player = player;
      _meters = meters;
      _bearing = bearing;
      _readings.add(meters);
      if (_readings.length > 3) _readings.removeAt(0);
    });
    _fetchRoute(player, target);
    if (!_fitted) {
      _fitted = true;
      Future.delayed(const Duration(milliseconds: 300), _recenter);
    }
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    final result = await widget.routeService.fetchWalkingRoute(from: from, to: to);
    if (result != null && mounted) setState(() => _route = result.points);
  }

  void _recenter() {
    final target = _target;
    final player = _player;
    if (!mounted || target == null) return;
    try {
      if (player == null) {
        _map.move(target, 17);
      } else {
        _map.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints([player, target]),
          padding: const EdgeInsets.all(40),
          maxZoom: 18,
        ));
      }
    } catch (_) {
      // The map is not laid out yet.
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = _target;
    final meters = _meters;
    return LocationPuzzleView(
      state: _state,
      map: target == null
          ? const SizedBox.shrink()
          : LocationMap(
              controller: _map,
              target: target,
              radius: widget.puzzle.radiusMeters,
              player: _player,
              route: _route,
              onRecenter: _recenter,
            ),
      meters: meters,
      bearing: _bearing,
      trend: trendOf(_readings),
      inside: meters != null && insideCircle(meters, widget.puzzle.radiusMeters),
      onEnter: widget.onSolved,
      onHint: widget.onHint,
      onOpenSettings: Geolocator.openAppSettings,
      onOpenLocationSettings: Geolocator.openLocationSettings,
      onPicture: widget.onPicture,
    );
  }
}
