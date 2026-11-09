import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/events_tab/logic/map_points.dart';
import 'package:teamxperience/model/event.dart';

Event _at(String id, double lat, double lng) => Event(eventId: id, name: id, startLatitude: lat, startLongitude: lng);

void main() {
  group('pins that share a spot', () {
    test('the same start becomes one group, in the order given', () {
      final groups = groupMapPoints(mapPoints([_at('a', 45.7971, 24.152), _at('b', 45.7971, 24.152), _at('c', 45.80, 24.16)]));
      expect(groups.map((g) => g.events.map((e) => e.eventId).toList()), [
        ['a', 'b'],
        ['c'],
      ]);
      expect(groups.first.at, const LatLng(45.7971, 24.152));
    });

    test('a few metres apart still share a pin; a street away does not', () {
      // 0.0001 degrees of latitude is about 11 m; 0.002 about 220 m.
      expect(groupMapPoints(mapPoints([_at('a', 45.7971, 24.152), _at('b', 45.7972, 24.152)])).length, 1);
      expect(groupMapPoints(mapPoints([_at('a', 45.7971, 24.152), _at('b', 45.7991, 24.152)])).length, 2);
    });

    test('nothing, nothing', () {
      expect(groupMapPoints(const []), isEmpty);
    });
  });

  test('only events with a start pin are on the map', () {
    final points = mapPoints([sampleEvent(), ...sampleOpenEvents(), Event(eventId: 'half', startLatitude: 45)]);
    expect(points.map((p) => p.$1.eventId), ['sample', 'cerber']);
    expect(points.first.$2, const LatLng(45.7971, 24.1520));
  });

  test('no points, no bounds; points give the box around them', () {
    expect(pointsBounds(const []), isNull);
    final b = pointsBounds(const [LatLng(45.79, 24.15), LatLng(45.80, 24.16)]);
    expect(b?.south, 45.79);
    expect(b?.north, 45.80);
    expect(b?.west, 24.15);
    expect(b?.east, 24.16);
  });
}
