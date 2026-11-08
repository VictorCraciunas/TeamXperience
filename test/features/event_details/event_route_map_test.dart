import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/features/event_details/widgets/event_route_map.dart';
import 'package:teamxperience/features/event_details/widgets/logistics_section.dart';
import 'package:teamxperience/features/event_details/widgets/mini_route_sketch.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/ui/ui.dart';

Event _event({bool finish = true}) => Event(
      eventId: 'e',
      startLatitude: 45.79,
      startLongitude: 24.15,
      finishLatitude: finish ? 45.80 : null,
      finishLongitude: finish ? 24.16 : null,
      missions: [
        Mission(id: '0', latitude: 45.81, longitude: 24.14),
        Mission(id: '1', latitude: 45.82, longitude: 24.17),
      ],
    );

Future<void> _pump(WidgetTester tester, Event event, {double width = 390}) async {
  tester.view.physicalSize = Size(width * 3, 700 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(child: LogisticsSection(event: event, showMapTiles: false)),
    ),
  ));
  await tester.pump();
}

void main() {
  testWidgets('with a start and a finish it shows the map', (tester) async {
    await _pump(tester, _event());
    expect(find.byType(EventRouteMap), findsOneWidget);
    expect(find.byType(MiniRouteSketch), findsNothing);
  });

  testWidgets('without a finish pin it keeps the sketch', (tester) async {
    await _pump(tester, _event(finish: false));
    expect(find.byType(FlutterMap), findsNothing);
    expect(find.byType(MiniRouteSketch), findsOneWidget);
  });

  testWidgets('only the start and the finish get a pin, and the line bends with the missions', (tester) async {
    await _pump(tester, _event());
    final markers = tester.widget<MarkerLayer>(find.byType(MarkerLayer)).markers;
    expect(markers.map((m) => m.point), const [LatLng(45.79, 24.15), LatLng(45.80, 24.16)]);
    final line = tester.widget<PolylineLayer>(find.byType(PolylineLayer)).polylines.single.points;
    expect(line.any((p) => p.latitude > 45.80), isTrue);
    expect(line.contains(const LatLng(45.81, 24.14)), isFalse);
    expect(line.contains(const LatLng(45.82, 24.17)), isFalse);
  });

  testWidgets('credits OpenStreetMap, as its tile policy asks', (tester) async {
    await _pump(tester, _event());
    expect(find.text('© OpenStreetMap'), findsOneWidget);
  });

  testWidgets('fits a narrow phone', (tester) async {
    await _pump(tester, _event(), width: 320);
    expect(tester.takeException(), isNull);
  });
}
