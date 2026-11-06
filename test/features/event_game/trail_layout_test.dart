import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/logic/trail_layout.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';

Event _event(int missions) => Event(
      eventId: 'e1',
      missions: [
        for (var i = 0; i < missions; i++) Mission(id: '$i', title: i == 1 ? null : 'Misiune $i'),
      ],
    );

void main() {
  group('trailStops', () {
    test('six missions at progress 3: three done, the current, the locked rest, the flag', () {
      final stops = trailStops(_event(6), 3, 'la 180 m de tine');
      expect(stops, hasLength(6));
      expect(stops[0], isA<DoneStop>().having((s) => s.label, 'label', '1 · Misiune 0'));
      expect(stops[1], isA<DoneStop>().having((s) => s.label, 'label', '2 · Misiunea 2'));
      expect(stops[2], isA<DoneStop>());
      expect(
        stops[3],
        isA<CurrentStop>()
            .having((s) => s.number, 'number', 4)
            .having((s) => s.title, 'title', 'Misiune 3')
            .having((s) => s.distance, 'distance', 'la 180 m de tine'),
      );
      expect(stops[4], isA<LockedStop>().having((s) => s.label, 'label', '5 · 6'));
      expect(stops[5], isA<FinishStop>());
    });

    test('everything done: all ticked and the flag, no card', () {
      final stops = trailStops(_event(6), 6, null);
      expect(stops.whereType<DoneStop>(), hasLength(6));
      expect(stops.whereType<CurrentStop>(), isEmpty);
      expect(stops.whereType<LockedStop>(), isEmpty);
      expect(stops.last, isA<FinishStop>());
    });

    test('progress past the end counts as everything done', () {
      expect(trailStops(_event(2), 9, null).whereType<DoneStop>(), hasLength(2));
    });

    test('one mission at the start: the current and the flag', () {
      final stops = trailStops(_event(1), 0, null);
      expect(stops, hasLength(2));
      expect(stops.first, isA<CurrentStop>().having((s) => s.distance, 'distance', isNull));
      expect(stops.last, isA<FinishStop>());
    });

    test('the last mission is current: no locked group', () {
      final stops = trailStops(_event(3), 2, null);
      expect(stops.whereType<LockedStop>(), isEmpty);
    });

    test('no missions: just the flag', () {
      expect(trailStops(_event(0), 0, null).single, isA<FinishStop>());
    });
  });

  group('trailPoints', () {
    test('bottom to top, alternating left and right, 100 apart', () {
      final points = trailPoints(5, width: 304);
      expect(points, hasLength(5));
      expect(points.first, const Offset(304 * .2, 4 * 100 + 40));
      expect(points[1], const Offset(304 * .68, 3 * 100 + 40));
      expect(points[2].dx, 304 * .2);
      expect(points.last.dy, 40);
    });

    test('the height the trail needs', () {
      expect(trailHeight(5), 4 * 100 + 80);
      expect(trailHeight(1), 80);
    });
  });

  group('trailPath', () {
    test('passes through every point', () {
      final points = trailPoints(4, width: 300);
      final path = trailPath(points);
      final metric = path.computeMetrics().single;
      expect(metric.getTangentForOffset(0)?.position, points.first);
      expect(metric.getTangentForOffset(metric.length)?.position.dx, closeTo(points.last.dx, 0.01));
      expect(metric.getTangentForOffset(metric.length)?.position.dy, closeTo(points.last.dy, 0.01));
      for (final p in points) {
        expect(path.getBounds().inflate(0.5).contains(p), isTrue);
      }
    });

    test('the length up to a point, for the solid part of the line', () {
      final points = trailPoints(4, width: 300);
      final path = trailPath(points);
      final upTo = trailLengthTo(points, 2);
      final metric = path.computeMetrics().single;
      final end = metric.getTangentForOffset(upTo)?.position;
      expect(end?.dx, closeTo(points[2].dx, 0.5));
      expect(end?.dy, closeTo(points[2].dy, 0.5));
      expect(trailLengthTo(points, 0), 0);
    });

    test('one point: an empty path', () {
      expect(trailPath([const Offset(10, 10)]).computeMetrics(), isEmpty);
    });
  });
}
