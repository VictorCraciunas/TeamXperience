import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/log-in/screen/log_in_screen.dart';
import 'package:teamxperience/features/sign-up/screen/sign_up.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

/// The real Poppins, since the square test font says nothing about fit.
Future<void> _loadPoppins() async {
  for (final file in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final loader = FontLoader('Poppins')..addFont(rootBundle.load('assets/fonts/Poppins-$file.ttf'));
    await loader.load();
  }
}

Future<void> _pumpSmallPhone(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(320 * 3, 568 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3)),
        child: app ?? const SizedBox.shrink(),
      ),
      home: screen,
    ),
  );
  await tester.pump();
}

/// The autofill hints of every field, top to bottom.
List<Iterable<String>?> _hints(WidgetTester tester) =>
    tester.widgetList<TextField>(find.byType(TextField)).map((f) => f.autofillHints).toList();

void main() {
  setUpAll(_loadPoppins);

  testWidgets('log-in: one autofill group of email and password, and it fits a small phone', (tester) async {
    await _pumpSmallPhone(tester, const LogInScreen());
    expect(tester.takeException(), isNull);

    final group = tester.widget<AutofillGroup>(find.byType(AutofillGroup));
    expect(group.onDisposeAction, AutofillContextAction.cancel);
    expect(find.descendant(of: find.byType(AutofillGroup), matching: find.byType(TextField)), findsNWidgets(2));
    expect(_hints(tester), [
      [AutofillHints.email],
      [AutofillHints.password],
    ]);
    final scroll = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    expect(scroll.keyboardDismissBehavior, ScrollViewKeyboardDismissBehavior.onDrag);
  });

  testWidgets('sign-up: email, names and a new password for the password manager, and it fits a small phone',
      (tester) async {
    await _pumpSmallPhone(tester, const RegisterScreen());
    expect(tester.takeException(), isNull);

    final group = tester.widget<AutofillGroup>(find.byType(AutofillGroup));
    expect(group.onDisposeAction, AutofillContextAction.cancel);
    expect(_hints(tester), [
      [AutofillHints.email],
      [AutofillHints.givenName],
      [AutofillHints.familyName],
      [AutofillHints.newPassword],
      [AutofillHints.newPassword],
    ]);
    final scroll = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    expect(scroll.keyboardDismissBehavior, ScrollViewKeyboardDismissBehavior.onDrag);
  });
}
