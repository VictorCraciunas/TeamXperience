import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:teamxperience/service/LocationService.dart';

void main() {
  test('Android: best accuracy, a fix every 2 s, the distance filter kept', () {
    final settings = positionSettings(distanceFilter: 2, platform: TargetPlatform.android, web: false);
    expect(settings, isA<AndroidSettings>());
    final android = settings as AndroidSettings;
    expect(android.accuracy, LocationAccuracy.best);
    expect(android.intervalDuration, const Duration(seconds: 2));
    expect(android.distanceFilter, 2);
    expect(android.foregroundNotificationConfig, isNull);
  });

  test('iOS and macOS: best accuracy, walking, never paused, no background', () {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
      final settings = positionSettings(distanceFilter: 10, platform: platform, web: false);
      expect(settings, isA<AppleSettings>());
      final apple = settings as AppleSettings;
      expect(apple.accuracy, LocationAccuracy.best);
      expect(apple.activityType, ActivityType.fitness);
      expect(apple.pauseLocationUpdatesAutomatically, isFalse);
      expect(apple.allowBackgroundLocationUpdates, isFalse);
      expect(apple.showBackgroundLocationIndicator, isFalse);
      expect(apple.distanceFilter, 10);
    }
  });

  test('elsewhere (web, tests): plain settings, best accuracy', () {
    final web = positionSettings(distanceFilter: 10, platform: TargetPlatform.android, web: true);
    expect(web, isNot(isA<AndroidSettings>()));
    expect(web.accuracy, LocationAccuracy.best);
    expect(web.distanceFilter, 10);
    final windows = positionSettings(distanceFilter: 5, platform: TargetPlatform.windows, web: false);
    expect(windows, isNot(isA<AndroidSettings>()));
    expect(windows, isNot(isA<AppleSettings>()));
    expect(windows.distanceFilter, 5);
  });
}
