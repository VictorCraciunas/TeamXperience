import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/profile/widgets/profile_view.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';
import 'package:teamxperience/ui/theme/theme_controller.dart';
import 'package:teamxperience/ui/theme/theme_mode_store.dart';

class _MemoryStore implements ThemeModeStore {
  @override
  Future<ThemeMode?> read() async => null;

  @override
  Future<void> write(ThemeMode mode) async {}
}

Future<ThemeController> _pump(
  WidgetTester tester, {
  VoidCallback? onLogout,
  VoidCallback? onTeams,
}) async {
  final controller = ThemeController(_MemoryStore());
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeController>.value(
      value: controller,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileView(
              name: 'Victor Crăciunaș',
              email: 'victor@example.com',
              onLogout: onLogout ?? () {},
              onTeams: onTeams ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
  return controller;
}

void main() {
  testWidgets('shows the name, email and initials', (tester) async {
    await _pump(tester);
    expect(find.text('Victor Crăciunaș'), findsOneWidget);
    expect(find.text('victor@example.com'), findsOneWidget);
    expect(find.text('VC'), findsOneWidget);
  });

  testWidgets('shows the three theme options with the current one selected', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Sistem'), findsOneWidget);
    expect(find.text('Luminos'), findsOneWidget);
    expect(find.text('Întunecat'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('theme-option-selected-light')),
      findsOneWidget,
    );
  });

  testWidgets('choosing a theme option updates the controller', (tester) async {
    final controller = await _pump(tester);
    await tester.tap(find.text('Întunecat'));
    await tester.pumpAndSettle();
    expect(controller.mode, ThemeMode.dark);
  });

  testWidgets('the logout button fires onLogout', (tester) async {
    var taps = 0;
    await _pump(tester, onLogout: () => taps++);
    await tester.tap(find.text('Deconectare'));
    expect(taps, 1);
  });

  testWidgets('the "Echipele mele" row opens the teams', (tester) async {
    var taps = 0;
    await _pump(tester, onTeams: () => taps++);
    expect(find.text('Echipele mele'), findsOneWidget);
    await tester.tap(find.text('Echipele mele'));
    expect(taps, 1);
  });

  testWidgets('a single-word or empty name still gives sensible initials', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeController>.value(
        value: ThemeController(_MemoryStore()),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfileView(
                name: 'Ana',
                email: 'a@b.ro',
                onLogout: () {},
                onTeams: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('A'), findsOneWidget);
  });
}
