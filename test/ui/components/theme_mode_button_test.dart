import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/ui/components/misc/theme_mode_button.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';
import 'package:teamxperience/ui/theme/theme_controller.dart';
import 'package:teamxperience/ui/theme/theme_mode_store.dart';

class _MemoryStore implements ThemeModeStore {
  ThemeMode? stored;

  @override
  Future<ThemeMode?> read() async => stored;

  @override
  Future<void> write(ThemeMode mode) async => stored = mode;
}

Future<ThemeController> _pump(WidgetTester tester, {ThemeMode? initial}) async {
  final store = _MemoryStore()..stored = initial;
  final controller = ThemeController(store);
  await controller.load();
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeController>.value(
      value: controller,
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,
          home: const Scaffold(body: Center(child: ThemeModeButton())),
        ),
      ),
    ),
  );
  return controller;
}

void main() {
  testWidgets('opens a sheet with the three options', (tester) async {
    await _pump(tester);
    await tester.tap(find.byType(ThemeModeButton));
    await tester.pumpAndSettle();
    expect(find.text('Sistem'), findsOneWidget);
    expect(find.text('Luminos'), findsOneWidget);
    expect(find.text('Întunecat'), findsOneWidget);
  });

  testWidgets('marks the current mode as selected', (tester) async {
    await _pump(tester, initial: ThemeMode.dark);
    await tester.tap(find.byType(ThemeModeButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('theme-option-selected-dark')), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-option-selected-light')), findsNothing);
  });

  testWidgets('choosing a mode applies it, saves it and closes the sheet',
      (tester) async {
    final controller = await _pump(tester);
    await tester.tap(find.byType(ThemeModeButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Întunecat'));
    await tester.pumpAndSettle();
    expect(controller.mode, ThemeMode.dark);
    expect(find.text('Luminos'), findsNothing);
    final context = tester.element(find.byType(ThemeModeButton));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
