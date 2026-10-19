import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';

void main() {
  testWidgets('builds with the current time and rebuilds on every interval', (tester) async {
    var clock = DateTime(2026, 10, 20, 12, 0, 0);
    final seen = <DateTime>[];

    await tester.pumpWidget(
      MaterialApp(
        home: ClockBuilder(
          interval: const Duration(seconds: 30),
          now: () => clock,
          builder: (context, now) {
            seen.add(now);
            return Text('${now.minute}:${now.second}');
          },
        ),
      ),
    );
    expect(seen.length, 1);
    expect(find.text('0:0'), findsOneWidget);

    clock = DateTime(2026, 10, 20, 12, 0, 30);
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('0:30'), findsOneWidget);
    expect(seen.length, 2);
  });

  testWidgets('stops ticking after it is removed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ClockBuilder(
          interval: const Duration(seconds: 1),
          builder: (context, now) => const SizedBox(),
        ),
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });
}
