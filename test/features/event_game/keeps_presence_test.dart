import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/widgets/keeps_presence.dart';

void main() {
  testWidgets('marks the player present after the first frame, then every minute', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: KeepsPresence(markPresent: () async => calls++, child: const Text('joc')),
    ));
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 60));
    await tester.pump(const Duration(seconds: 60));
    expect(calls, 3);
  });

  testWidgets('stops once the game screen is gone', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: KeepsPresence(markPresent: () async => calls++, child: const Text('joc')),
    ));
    await tester.pumpWidget(const MaterialApp(home: Text('acasă')));
    final before = calls;
    await tester.pump(const Duration(seconds: 120));
    expect(calls, before);
  });

  testWidgets('a failed write does not break anything, and the next minute tries again', (tester) async {
    var calls = 0;
    Future<void> failing() async {
      calls++;
      throw Exception('offline');
    }

    await tester.pumpWidget(MaterialApp(home: KeepsPresence(markPresent: failing, child: const Text('joc'))));
    await tester.pump(const Duration(seconds: 60));
    expect(tester.takeException(), isNull);
    expect(calls, 2);
  });

  testWidgets('not ready yet: nothing; the moment it is ready, at once, then every minute', (tester) async {
    var calls = 0;
    Widget app(bool ready) => MaterialApp(
          home: KeepsPresence(ready: ready, markPresent: () async => calls++, child: const Text('start')),
        );
    await tester.pumpWidget(app(false));
    await tester.pump(const Duration(seconds: 30));
    expect(calls, 0);
    await tester.pumpWidget(app(true));
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 60));
    expect(calls, 2);
  });
}
