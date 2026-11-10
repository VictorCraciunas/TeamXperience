import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:teamxperience/features/loader_page/widgets/brand_splash.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../../ui/pump_ui.dart';

void main() {
  test('the animation loads, with the intro and the loop marked', () async {
    final bytes = File(BrandSplash.asset).readAsBytesSync();
    final composition = await LottieComposition.fromBytes(bytes);
    final loop = composition.getMarker('loop');
    expect(loop, isNotNull);
    expect(loop?.start, inExclusiveRange(0, 1));
  });

  testWidgets('the logo plays on the app navy, and fits a small phone', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpUi(tester, const BrandSplash());
    expect(find.byType(Lottie), findsOneWidget);
    final page = tester.widget<ColoredBox>(find.byKey(const ValueKey('brand-splash')));
    expect(page.color, AppColors.light.navy);
    expect(tester.takeException(), isNull);
  });
}
