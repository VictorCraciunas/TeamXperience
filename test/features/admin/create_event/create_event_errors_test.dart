import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/create_event/create_event_landing/screen/create_event_screen.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

void main() {
  testWidgets('a wrong field: the page goes to it and a snackbar says what is wrong', (tester) async {
    tester.view.physicalSize = const Size(780, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const CreateEventPage()));
    await tester.pumpAndSettle();

    final button = find.text('Continuă la misiuni');
    await tester.scrollUntilVisible(button, 400, scrollable: find.byType(Scrollable).first);
    final name = find.text('Nume');
    expect(tester.getRect(name).top, lessThan(0), reason: 'the name field is scrolled away');

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Corectează câmpul marcat'), findsOneWidget);
    expect(tester.getRect(name).top, greaterThanOrEqualTo(0), reason: 'the first wrong field is back on screen');
  });
}
