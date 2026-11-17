import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/splash/splash.dart';
import 'package:teamxperience/ui/components/misc/brand_title.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

/// The real Poppins, since the square test font says nothing about fit.
Future<void> _loadPoppins() async {
  for (final file in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final loader = FontLoader('Poppins')..addFont(rootBundle.load('assets/fonts/Poppins-$file.ttf'));
    await loader.load();
  }
}

void main() {
  setUpAll(_loadPoppins);

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('the brand is drawn as text, not the old logo image, and fits a small phone '
        '(${theme.brightness.name})', (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          builder: (context, app) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: app ?? const SizedBox.shrink(),
          ),
          home: const SplashScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(BrandTitle), findsOneWidget);
      expect(find.text('TeamXperience'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.text('Loghează-te'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
