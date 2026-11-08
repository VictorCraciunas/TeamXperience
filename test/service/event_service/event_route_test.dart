import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/service/event_service/event_route.dart';

Mission _pinned(double lat, double lng) => Mission(id: 'm', latitude: lat, longitude: lng);

void main() {
  group('routePoints', () {
    test('runs from the start through the missions to the finish', () {
      final event = Event(
        eventId: 'e',
        startLatitude: 1,
        startLongitude: 2,
        finishLatitude: 7,
        finishLongitude: 8,
        missions: [_pinned(3, 4), Mission(id: 'none'), _pinned(5, 6)],
      );
      expect(routePoints(event), const [LatLng(1, 2), LatLng(3, 4), LatLng(5, 6), LatLng(7, 8)]);
    });

    test('a mission without a pin goes by its location puzzle', () {
      final event = Event(eventId: 'e', missions: [
        Mission(id: 'm', puzzles: [
          Puzzle(id: '0', type: PuzzleType.code),
          Puzzle(id: '1', type: PuzzleType.geolocation, latitude: 3, longitude: 4),
        ]),
      ]);
      expect(routePoints(event), const [LatLng(3, 4)]);
    });

    test('the pin on a mission wins over its puzzle', () {
      final event = Event(eventId: 'e', missions: [
        Mission(id: 'm', latitude: 1, longitude: 2, puzzles: [
          Puzzle(id: '0', type: PuzzleType.geolocation, latitude: 3, longitude: 4),
        ]),
      ]);
      expect(routePoints(event), const [LatLng(1, 2)]);
    });
  });

  group('smoothLine', () {
    test('two points stay as they are', () {
      const points = [LatLng(1, 2), LatLng(3, 4)];
      expect(smoothLine(points), points);
    });

    test('nothing to smooth', () {
      expect(smoothLine(const []), isEmpty);
      expect(smoothLine(const [LatLng(1, 2)]), const [LatLng(1, 2)]);
    });

    test('keeps both ends exactly and adds points in between', () {
      const points = [LatLng(0, 0), LatLng(1, 1), LatLng(0, 2)];
      final line = smoothLine(points);
      expect(line.first, points.first);
      expect(line.last, points.last);
      expect(line.length, greaterThan(points.length));
    });

    test('rounds the corner at a mission rather than turning sharply on it', () {
      const points = [LatLng(0, 0), LatLng(1, 1), LatLng(0, 2)];
      final line = smoothLine(points);
      final corner = line.indexOf(points[1]);
      final before = line[corner - 1];
      final after = line[corner + 1];
      // Straight legs would drop by a whole step on each side of the bend.
      // A rounded line stays nearly level over the top of it.
      expect(1 - before.latitude, lessThan(0.05));
      expect(1 - after.latitude, lessThan(0.05));
    });

    test('the same point twice does not break it', () {
      const points = [LatLng(1, 1), LatLng(1, 1), LatLng(2, 2)];
      expect(smoothLine(points).every((p) => p.latitude.isFinite && p.longitude.isFinite), isTrue);
    });
  });
}
