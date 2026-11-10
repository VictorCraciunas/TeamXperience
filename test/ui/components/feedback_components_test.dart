import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';

void main() {
  group('showAppDialog', () {
    bool? result;

    Future<void> open(WidgetTester tester, {bool destructive = false}) async {
      result = null;
      await pumpUi(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showAppDialog(
                context,
                title: 'Titlu',
                message: 'Mesaj',
                confirmLabel: 'Șterge',
                cancelLabel: 'Anulează',
                destructive: destructive,
              );
            },
            child: const Text('deschide'),
          ),
        ),
      );
      await tester.tap(find.text('deschide'));
      await tester.pumpAndSettle();
    }

    testWidgets('returns true on confirm', (tester) async {
      await open(tester);
      expect(find.text('Titlu'), findsOneWidget);
      expect(find.text('Mesaj'), findsOneWidget);
      await tester.tap(find.text('Șterge'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('returns false on cancel', (tester) async {
      await open(tester);
      await tester.tap(find.text('Anulează'));
      await tester.pumpAndSettle();
      expect(find.text('Titlu'), findsNothing);
      expect(result, isFalse);
    });

    testWidgets('a destructive confirm uses the danger colour', (tester) async {
      await open(tester, destructive: true);
      final text = tester.widget<Text>(find.text('Șterge'));
      expect(text.style?.color, AppColors.light.danger);
    });
  });

  group('MySnackBars', () {
    Future<Color?> background(
      WidgetTester tester,
      void Function(BuildContext) show, {
      ThemeData? theme,
    }) async {
      await pumpUi(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => show(context),
            child: const Text('arată'),
          ),
        ),
        theme: theme,
      );
      await tester.tap(find.text('arată'));
      await tester.pump();
      return tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor;
    }

    testWidgets('use the semantic tokens', (tester) async {
      expect(
        await background(tester, (c) => MySnackBars.successSnackBar(c, title: 'ok')),
        AppColors.light.success,
      );
      await tester.pumpWidget(const SizedBox());
      expect(
        await background(tester, (c) => MySnackBars.errorSnackBar(c, title: 'x')),
        AppColors.light.danger,
      );
      await tester.pumpWidget(const SizedBox());
      expect(
        await background(tester, (c) => MySnackBars.warningSnackBar(c, title: 'x')),
        AppColors.light.warning,
      );
      await tester.pumpWidget(const SizedBox());
      expect(
        await background(tester, (c) => MySnackBars.infoSnackBar(c, title: 'x')),
        AppColors.light.accent,
      );
    });

    testWidgets('follow the dark theme', (tester) async {
      expect(
        await background(
          tester,
          (c) => MySnackBars.errorSnackBar(c, title: 'x'),
          theme: AppTheme.dark,
        ),
        AppColors.dark.danger,
      );
    });
  });

  test('semantic soft backgrounds differ from the page in both themes', () {
    expect(AppColors.light.dangerSoft, isNot(AppColors.light.page));
    expect(AppColors.dark.successSoft, isNot(AppColors.dark.page));
  });
}
