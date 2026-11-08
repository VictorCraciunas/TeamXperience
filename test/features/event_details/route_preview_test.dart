import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/features/event_details/logic/route_preview.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';

Event _event({bool start = true, bool finish = true}) => Event(
      eventId: 'e',
      startLatitude: start ? 45.79 : null,
      startLongitude: start ? 24.15 : null,
      finishLatitude: finish ? 45.80 : null,
      finishLongitude: finish ? 24.16 : null,
      missions: [Mission(id: 'm', latitude: 45.81, longitude: 24.14)],
    );

void main() {
  test('needs both the start and the finish', () {
    expect(routePreviewOf(_event(start: false)), isNull);
    expect(routePreviewOf(_event(finish: false)), isNull);
  });

  test('the pins are the start and the finish, and the line bends towards the mission without reaching it', () {
    final preview = routePreviewOf(_event());
    expect(preview?.start, const LatLng(45.79, 24.15));
    expect(preview?.finish, const LatLng(45.80, 24.16));
    expect(preview?.line.contains(const LatLng(45.81, 24.14)), isFalse);
    expect(preview?.line.any((p) => p.latitude > 45.80), isTrue);
    expect(preview?.line.first, preview?.start);
    expect(preview?.line.last, preview?.finish);
  });
}
