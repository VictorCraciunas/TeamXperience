import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('shows a trailing widget', (tester) async {
    await pumpUi(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: TabHeader(title: 'Evenimente', trailing: Text('T'), bottom: SizedBox(key: ValueKey('b'), height: 20)),
      ),
    );
    expect(find.text('T'), findsOneWidget);
  });
}
