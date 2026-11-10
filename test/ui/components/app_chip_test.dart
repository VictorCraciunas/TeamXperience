import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('shows its label and icon', (tester) async {
    await pumpUi(tester, const AppChip(label: 'Coduri', icon: TablerIcons.key));
    expect(find.text('Coduri'), findsOneWidget);
    expect(find.byIcon(TablerIcons.key), findsOneWidget);
  });

  testWidgets('a tap calls onTap', (tester) async {
    var taps = 0;
    await pumpUi(tester, AppChip(label: 'Luna asta', onTap: () => taps++));
    await tester.tap(find.text('Luna asta'));
    expect(taps, 1);
  });

  testWidgets('a tappable chip has a hit area at least 32 tall', (tester) async {
    await pumpUi(tester, AppChip(label: 'Toate', onTap: () {}));
    expect(tester.getSize(find.byType(AppChip)).height, greaterThanOrEqualTo(32));
  });
}
