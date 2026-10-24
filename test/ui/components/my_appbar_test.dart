import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, MyAppBar bar) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(appBar: bar),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the title and subtitle', (tester) async {
    await _pump(tester, const MyAppBar(appBarText: 'Puzzle 1', subtitle: 'Cod'));
    expect(find.text('Puzzle 1'), findsOneWidget);
    expect(find.text('Cod'), findsOneWidget);
  });

  testWidgets('without tabs it is the usual height', (tester) async {
    await _pump(tester, const MyAppBar(appBarText: 'Misiuni'));
    expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight);
  });

  testWidgets('tabs sit under the title and add to the height', (tester) async {
    await _pump(
      tester,
      const MyAppBar(
        appBarText: 'Puzzle 1',
        bottom: TabBar(tabs: [Tab(text: 'Aspect'), Tab(text: 'Reguli')]),
      ),
    );
    expect(find.text('Aspect'), findsOneWidget);
    expect(find.text('Reguli'), findsOneWidget);
    expect(tester.getSize(find.byType(AppBar)).height, greaterThan(kToolbarHeight));
  });
}
