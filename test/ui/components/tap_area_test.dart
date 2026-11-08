import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/live_room/widgets/board_action_button.dart';
import 'package:teamxperience/features/live_room/widgets/live_header_action.dart';
import 'package:teamxperience/features/live_room/widgets/queue_round_button.dart';
import 'package:teamxperience/ui/components/game/game_filled_button.dart';
import 'package:teamxperience/ui/components/game/game_icon_button.dart';
import 'package:teamxperience/ui/components/game/game_outline_button.dart';
import 'package:teamxperience/ui/components/game/round_icon_button.dart';
import 'package:teamxperience/ui/components/misc/tap_area.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('a small drawing gets 48 px, and the whole area answers', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: TapArea(onTap: () => taps++, child: const SizedBox.square(key: ValueKey('drawn'), dimension: 32)),
      ),
    );
    expect(tester.getSize(find.byType(TapArea)), const Size(48, 48));
    expect(tester.getSize(find.byKey(const ValueKey('drawn'))), const Size(32, 32));
    final centre = tester.getCenter(find.byKey(const ValueKey('drawn')));
    await tester.tapAt(centre + const Offset(20, 20));
    expect(taps, 1);
  });

  testWidgets('something bigger keeps its size', (tester) async {
    await pumpUi(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: TapArea(onTap: () {}, child: const SizedBox(width: 120, height: 60)),
      ),
    );
    expect(tester.getSize(find.byType(TapArea)), const Size(120, 60));
  });

  testWidgets('no callback: nothing answers', (tester) async {
    await pumpUi(tester, const TapArea(onTap: null, child: SizedBox.square(dimension: 32)));
    await tester.tap(find.byType(TapArea), warnIfMissed: false);
    expect(tester.takeException(), isNull);
  });

  final controls = <String, Widget>{
    'RoundIconButton': RoundIconButton(icon: TablerIcons.x, onTap: () {}),
    'GameIconButton': GameIconButton(icon: TablerIcons.x, label: 'x', onTap: () {}),
    'GameOutlineButton': GameOutlineButton(label: 'Indiciu', onTap: () {}),
    'GameFilledButton': GameFilledButton(label: 'Continuă', onTap: () {}),
    'QueueRoundButton': QueueRoundButton(icon: TablerIcons.x, label: 'x', ink: Colors.red, onTap: () {}),
    'LiveHeaderAction': LiveHeaderAction(icon: TablerIcons.x, label: 'x', onTap: () {}),
    'BoardActionButton': BoardActionButton(label: 'Anunț', icon: TablerIcons.x, colour: Colors.red, onTap: () {}),
  };
  for (final entry in controls.entries) {
    testWidgets('${entry.key} is at least 48 px tall to tap', (tester) async {
      await pumpUi(tester, Align(alignment: Alignment.topLeft, child: entry.value));
      expect(tester.getSize(find.byWidget(entry.value)).height, greaterThanOrEqualTo(48));
    });
  }
}
