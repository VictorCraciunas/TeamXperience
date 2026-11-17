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

  testWidgets('the icon button calls what the page gives it', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      MyAppBar(
        appBarText: 'Detalii Eveniment',
        iconString: 'assets/images/menu.svg',
        iconLabel: 'Mai multe acțiuni',
        onIconTap: () => taps++,
      ),
    );
    await tester.tap(find.bySemanticsLabel('Mai multe acțiuni'));
    expect(taps, 1);
  });
}
