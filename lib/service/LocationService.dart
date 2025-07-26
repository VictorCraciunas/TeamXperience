import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  TeamService teamService = TeamService();

  String? _currentEventId;
  String? _currentTeamName;
  bool _isTracking = false;

  // Start location tracking for a team
  Future<void> startLocationTracking({
    required String eventId,
    required String teamName,
  }) async {
    if (_isTracking) {
      // If already tracking, stop previous tracking first
      stopLocationTracking();
    }

    _currentEventId = eventId;
    _currentTeamName = teamName;

    // Request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions permanently denied');
      return;
    }

    // Configure location settings
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    // Start listening to position updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
          (Position position) async {
        await _updateTeamLocation(position);
      },
      onError: (error) {
        print('Location tracking error: $error');
      },
    );

    _isTracking = true;
    print('Location tracking started for team: $teamName');
  }

  // Update team location in Firebase using TeamService
  Future<void> _updateTeamLocation(Position position) async {
    if (_currentEventId == null || _currentTeamName == null) return;

    try {
      await teamService.updateTeamLocation(
        _currentEventId!,
        _currentTeamName!,
        position.latitude,
        position.longitude,
      );
      print('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Failed to update team location: $e');
    }
  }

  // Stop location tracking
  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    _currentEventId = null;
    _currentTeamName = null;
    print('Location tracking stopped');
  }

  // Check if currently tracking
  bool get isTracking => _isTracking;

  // Get current tracking info
  Map<String, String?> get trackingInfo => {
    'eventId': _currentEventId,
    'teamName': _currentTeamName,
  };
}