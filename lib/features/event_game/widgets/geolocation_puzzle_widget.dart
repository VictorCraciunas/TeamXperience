import 'dart:async';

import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/service/LocationService.dart';
import 'package:teamxperience/service/route_service.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

class GeolocationPuzzleWidget extends StatefulWidget {
  final Puzzle puzzle;
  final VoidCallback onSolved;
  final bool isMissionCompleted;
  final RouteService routeService;

  const GeolocationPuzzleWidget({
    super.key,
    required this.puzzle,
    required this.onSolved,
    required this.routeService,
    this.isMissionCompleted = false,
  });

  @override
  State<GeolocationPuzzleWidget> createState() =>
      _GeolocationPuzzleWidgetState();
}

class _GeolocationPuzzleWidgetState extends State<GeolocationPuzzleWidget> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _currentPosition;
  bool _isInsideCircle = false;
  bool _locationError = false;
  String _errorMessage = '';
  List<LatLng> _routePoints = [];
  double? _straightLineDistance;
  double? _routeDistance;
  bool _hasInitialFit = false;

  static const double _circleRadiusMeters = 20.0;

  LatLng get _targetPosition =>
      LatLng(widget.puzzle.latitude ?? 0, widget.puzzle.longitude ?? 0);

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    final hasPermission = await _locationService.checkAndRequestPermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _locationError = true;
          _errorMessage = 'Permisiunea de localizare nu a fost acordată.';
        });
      }
      return;
    }

    // Get initial position immediately
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        final userLatLng = LatLng(position.latitude, position.longitude);
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _targetPosition.latitude,
          _targetPosition.longitude,
        );
        setState(() {
          _currentPosition = userLatLng;
          _isInsideCircle = distance <= _circleRadiusMeters;
          _straightLineDistance = distance;
        });
        _fetchRoute(userLatLng);
        _fitMapToBounds(userLatLng);
      }
    } catch (_) {}

    _positionSubscription = _locationService
        .getPositionStream(distanceFilter: 2)
        .listen(
          (Position position) {
            final userLatLng = LatLng(position.latitude, position.longitude);
            final distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              _targetPosition.latitude,
              _targetPosition.longitude,
            );

            if (mounted) {
              setState(() {
                _currentPosition = userLatLng;
                _isInsideCircle = distance <= _circleRadiusMeters;
                _straightLineDistance = distance;
              });
              _fetchRoute(userLatLng);
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _locationError = true;
                _errorMessage = 'Eroare la localizare: $error';
              });
            }
          },
        );
  }

  void _fitMapToBounds(LatLng userPosition) {
    if (_hasInitialFit) return;
    _hasInitialFit = true;

    final bounds = LatLngBounds.fromPoints([userPosition, _targetPosition]);
    // Delay to ensure map is rendered
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
        );
      }
    });
  }

  Future<void> _fetchRoute(LatLng from) async {
    final result = await widget.routeService.fetchWalkingRoute(
      from: from,
      to: _targetPosition,
    );

    if (result != null && mounted) {
      setState(() {
        _routePoints = result.points;
        _routeDistance = result.distanceMeters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_locationError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _targetPosition,
                  initialZoom: 17.0,
                  maxZoom: 19.0,
                  minZoom: 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_map_test',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _targetPosition,
                        width: 60,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.accent.withValues(
                              alpha: 0.25,
                            ),
                            border: Border.all(
                              color: context.colors.accent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.colors.accent.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 4.0,
                          color: context.colors.accent,
                        ),
                      ],
                    ),
                  if (_currentPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition ?? _targetPosition,
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isInsideCircle || widget.isMissionCompleted)
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: AppButton(label: 'Continuă', onPressed: widget.onSolved),
          ),
        if (!_isInsideCircle &&
            !widget.isMissionCompleted &&
            _currentPosition != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                if (_routeDistance != null || _straightLineDistance != null)
                  Text(
                    RouteService.formatDistance(
                      _routeDistance ?? _straightLineDistance!,
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Deplasează-te spre zona marcată',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
