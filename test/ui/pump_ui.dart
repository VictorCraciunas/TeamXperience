import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<void> pumpUi(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  double textScale = 1,
  double width = 360,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: app ?? const SizedBox.shrink(),
      ),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}
