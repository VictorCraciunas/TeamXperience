import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/events_tab/logic/map_points.dart';
import 'package:teamxperience/model/event.dart';

void main() {
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
