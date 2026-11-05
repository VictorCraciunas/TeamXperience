import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/widgets/refreshes_active_game.dart';

void main() {
  testWidgets('refreshes once the game screen is shown and again when it closes', (tester) async {
    var refreshes = 0;
    Future<void> refresh() async => refreshes++;

    await tester.pumpWidget(MaterialApp(
      home: RefreshesActiveGame(refresh: refresh, child: const Text('joc')),
    ));
    expect(refreshes, 1);

    await tester.pumpWidget(const MaterialApp(home: Text('acasă')));
    await tester.pump();
    expect(refreshes, 2);
  });

  testWidgets('a refresh that notifies listeners does not break the frame', (tester) async {
    final source = ValueNotifier(0);
    addTearDown(source.dispose);
    Future<void> refresh() async => source.value++;

    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<int>(
        valueListenable: source,
        builder: (_, value, _) => value < 1
            ? RefreshesActiveGame(refresh: refresh, child: Text('$value'))
            : Text('gata $value'),
      ),
    ));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('gata 2'), findsOneWidget);
  });
}
