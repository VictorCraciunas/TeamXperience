import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/widgets/frame_band.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import '../../ui/pump_ui.dart';

void main() {
  testWidgets('over a picture, the frame sits on the page colour at 85 %', (tester) async {
    await pumpUi(
      tester,
      const EventThemeScope(
        palette: EventPalette.parchment,
        child: FrameBand(onPicture: true, child: Text('Misiunea 4 din 6')),
      ),
    );
    final band = tester.widget<ColoredBox>(
      find.ancestor(of: find.text('Misiunea 4 din 6'), matching: find.byKey(const ValueKey('frame-band'))),
    );
    expect(band.color, EventPalette.parchment.background.withValues(alpha: .85));
  });

  testWidgets('without a picture, no band', (tester) async {
    await pumpUi(
      tester,
      const EventThemeScope(
        palette: EventPalette.parchment,
        child: FrameBand(onPicture: false, child: Text('Misiunea 4 din 6')),
      ),
    );
    expect(find.byKey(const ValueKey('frame-band')), findsNothing);
    expect(find.text('Misiunea 4 din 6'), findsOneWidget);
  });
}
