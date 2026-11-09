import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:teamxperience/features/loader_page/widgets/brand_splash.dart';

/// Pixels close to the brand yellow (#F6AF1A) in the logo at [progress].
Future<int> _yellowAt(WidgetTester tester, LottieComposition composition, double progress) async {
  final key = GlobalKey();
  await tester.pumpWidget(Center(
    child: RepaintBoundary(
      key: key,
      child: Lottie(composition: composition, width: 462, height: 125, controller: AlwaysStoppedAnimation(progress)),
    ),
  ));
  final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
  return (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    var yellow = 0;
    if (data == null) return 0;
    for (var i = 0; i < data.lengthInBytes; i += 4) {
      final (r, g, b) = (data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2));
      if (r > 200 && g > 140 && g < 200 && b < 80) yellow++;
    }
    return yellow;
  })) ?? 0;
}

void main() {
  testWidgets('the yellow X is drawn once the intro has played', (tester) async {
    final composition = await tester.runAsync(() => LottieComposition.fromBytes(File(BrandSplash.asset).readAsBytesSync()));
    if (composition == null) fail('the animation did not load');
    final loopStart = composition.getMarker('loop')?.start ?? 1;
    expect(await _yellowAt(tester, composition, loopStart), greaterThan(300));
    expect(await _yellowAt(tester, composition, 1), greaterThan(300));
  });
}
