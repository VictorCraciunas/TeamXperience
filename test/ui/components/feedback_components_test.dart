import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/ui/components/feedback/async_state.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';

Widget _asyncState({
  bool isLoading = false,
  Object? error,
  bool isEmpty = false,
  VoidCallback? onRetry,
}) {
  return AsyncState(
    isLoading: isLoading,
    error: error,
    isEmpty: isEmpty,
    onRetry: onRetry,
    emptyMessage: 'Nimic aici',
    child: const Text('conținut'),
  );
}

void main() {
  group('AsyncState', () {
    testWidgets('shows a spinner while loading', (tester) async {
      await pumpUi(tester, _asyncState(isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('conținut'), findsNothing);
    });

    testWidgets('shows the error with a retry button', (tester) async {
      var retries = 0;
      await pumpUi(tester, _asyncState(error: 'eșec', onRetry: () => retries++));
      expect(find.text('Reîncearcă'), findsOneWidget);
      await tester.tap(find.text('Reîncearcă'));
      expect(retries, 1);
    });

    testWidgets('shows the empty message', (tester) async {
      await pumpUi(tester, _asyncState(isEmpty: true));
      expect(find.text('Nimic aici'), findsOneWidget);
      expect(find.text('conținut'), findsNothing);
    });

    testWidgets('shows the child otherwise', (tester) async {
      await pumpUi(tester, _asyncState());
      expect(find.text('conținut'), findsOneWidget);
    });
  });

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
