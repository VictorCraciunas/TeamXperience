import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:teamxperience/service/location_filter.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/service/walk_tracker.dart';

/// How often Android is asked for a fix while the game follows the phone.
const Duration fixInterval = Duration(seconds: 2);

/// The one place the app's location settings are chosen; every stream and
/// one-off fix uses them. Only while the app is open: no background updates
/// and no new permissions.
///
/// - Android: best accuracy (GPS through the fused provider) and a fix every
///   [fixInterval] instead of the default 5 s.
/// - iOS/macOS: best accuracy (`high` there is only "nearest ten metres"),
///   walking as the activity, and updates never paused automatically.
/// - Elsewhere (web, tests): plain settings with best accuracy.
LocationSettings positionSettings({
  int distanceFilter = 0,
  TargetPlatform? platform,
  bool web = kIsWeb,
}) {
  if (web) return LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: distanceFilter);
  return switch (platform ?? defaultTargetPlatform) {
    TargetPlatform.android => AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
        intervalDuration: fixInterval,
      ),
    TargetPlatform.iOS || TargetPlatform.macOS => AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: false,
        showBackgroundLocationIndicator: false,
      ),
    _ => LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: distanceFilter),
  };
}

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

  /// Every position the phone reports (unfiltered), with [positionSettings].
  Stream<Position> getPositionStream({int distanceFilter = 10}) {
    return Geolocator.getPositionStream(locationSettings: positionSettings(distanceFilter: distanceFilter));
  }

  /// Positions without the poor readings ([LocationFilter]: one worse than
  /// 30 m is skipped while a better one is under 10 s old). With
  /// [withCurrentFix], a one-off fix is asked for at once too, so the first
  /// position does not wait for the stream; its errors are ignored.
  Stream<Position> accuratePositions({int distanceFilter = 10, bool withCurrentFix = false}) {
    final stream = getPositionStream(distanceFilter: distanceFilter);
    final source = withCurrentFix ? _withCurrentFix(stream) : stream;
    return filterFixes<Position>(source, accuracyOf: (position) => position.accuracy);
  }

  /// [stream] plus one fix from `getCurrentPosition`, whichever comes first.
  Stream<Position> _withCurrentFix(Stream<Position> stream) {
    final out = StreamController<Position>();
    StreamSubscription<Position>? subscription;
    out.onListen = () {
      subscription = stream.listen(out.add, onError: out.addError, onDone: out.close);
      Geolocator.getCurrentPosition(locationSettings: positionSettings()).then((position) {
        if (!out.isClosed && out.hasListener) out.add(position);
      }, onError: (Object _) {});
    };
    out.onPause = () => subscription?.pause();
    out.onResume = () => subscription?.resume();
    out.onCancel = () => subscription?.cancel();
    return out.stream;
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

    _positionStream = accuratePositions(distanceFilter: 10).listen(
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
