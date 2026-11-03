import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/route/route_strip.dart';
import 'package:teamxperience/ui/components/route/route_trail.dart';
import 'package:teamxperience/ui/components/route/route_trail_section.dart';
import 'package:teamxperience/ui/components/route/waypoint_dot.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('the strip shows the route, start and end', (tester) async {
    await pumpUi(
      tester,
      const RouteStrip(centerLabel: '4,5 km · 6 misiuni', startLabel: 'Piața Mare', endLabel: 'Turnul Sfatului'),
    );
    expect(find.text('4,5 km · 6 misiuni'), findsOneWidget);
    expect(find.text('Piața Mare'), findsOneWidget);
    expect(find.text('Turnul Sfatului'), findsOneWidget);
  });

  testWidgets('the map chip calls onMapTap', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      RouteStrip(
        centerLabel: '4,5 km',
        startLabel: 'A',
        endLabel: 'B',
        mapLabel: 'Hartă',
        onMapTap: () => taps++,
      ),
    );
    await tester.tap(find.text('Hartă'));
    expect(taps, 1);
  });

  testWidgets('there is no map chip without onMapTap', (tester) async {
    await pumpUi(tester, const RouteStrip(centerLabel: '4,5 km', startLabel: 'A', endLabel: 'B', mapLabel: 'Hartă'));
    expect(find.byType(AppChip), findsNothing);
  });

  testWidgets('the strip fits a narrow phone with large text', (tester) async {
    await pumpUi(
      tester,
      RouteStrip(
        centerLabel: '4,5 km · 6 misiuni',
        startLabel: 'Piața Mare',
        endLabel: 'Turnul Sfatului',
        mapLabel: 'Hartă',
        onMapTap: () {},
      ),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the trail gives each section a waypoint, the last one the finish', (tester) async {
    await pumpUi(
      tester,
      const RouteTrail(sections: [
        RouteTrailSection(child: Text('Povestea')),
        RouteTrailSection(child: Text('Ce vă așteaptă')),
        RouteTrailSection(kind: WaypointKind.finish, child: Text('Organizator')),
      ]),
    );
    final dots = tester.widgetList<WaypointDot>(find.byType(WaypointDot)).toList();
    expect(dots, hasLength(3));
    expect(dots.last.kind, WaypointKind.finish);
    expect(dots.first.kind, WaypointKind.stop);
  });

  testWidgets('trail content starts 40 in, waypoints at 14', (tester) async {
    await pumpUi(tester, const RouteTrail(sections: [RouteTrailSection(child: Text('Povestea'))]));
    final trailLeft = tester.getTopLeft(find.byType(RouteTrail)).dx;
    expect(tester.getTopLeft(find.text('Povestea')).dx - trailLeft, 40);
    expect(tester.getTopLeft(find.byType(WaypointDot)).dx - trailLeft, 14);
  });

  testWidgets('the strip is as tall as in the mockup', (tester) async {
    await pumpUi(tester, const RouteStrip(centerLabel: 'A', startLabel: 'B', endLabel: 'C'));
    // 12 padding, icon row on a 16 x 1.45 line, 4 gap, names 11 x 1.45, 12 padding, 1 border.
    expect(tester.getSize(find.byType(RouteStrip)).height, closeTo(12 + 23.2 + 4 + 15.95 + 12 + 1, 0.5));
  });
}
