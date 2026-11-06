import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/service/walk_tracker.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  TeamService teamService = TeamService();

  String? _currentEventId;
  String? _currentTeamName;
  bool _isTracking = false;

  /// The signed-in player, whose own walk this phone adds to `walked.{uid}`.
  String? _uid;
  WalkTracker _walk = WalkTracker();

  /// Checks and requests location permissions.
  /// Returns true if permissions are granted, false otherwise.
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  /// Returns a position stream with configurable distance filter.
  Stream<Position> getPositionStream({int distanceFilter = 10}) {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Start location tracking for a team
  Future<void> startLocationTracking({
    required String eventId,
    required String teamName,
    String? uid,
  }) async {
    if (_isTracking) {
      stopLocationTracking();
    }

    _currentEventId = eventId;
    _currentTeamName = teamName;
    _uid = uid;
    _walk = WalkTracker();

    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      print('Location permissions not granted');
      return;
    }

    _positionStream = getPositionStream(distanceFilter: 10).listen(
      (Position position) async {
        _countWalk(position);
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

  /// Adds this fix to the phone's walk and sends it in steps of 20 m.
  void _countWalk(Position position) {
    _walk.add(WalkFix(
      lat: position.latitude,
      lng: position.longitude,
      accuracy: position.accuracy,
      at: position.timestamp,
    ));
    _sendWalk(_walk.takePending());
  }

  void _sendWalk(double metres) {
    final eventId = _currentEventId;
    final teamName = _currentTeamName;
    final uid = _uid;
    if (metres <= 0 || eventId == null || teamName == null || uid == null) return;
    teamService.addWalked(eventId, teamName, uid, metres).catchError((Object _) {});
  }

  // Stop location tracking
  void stopLocationTracking() {
    // What was walked since the last step still counts.
    _sendWalk(_walk.takePending(atLeast: 0));
    _uid = null;
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
