import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/component_gallery.dart';
import 'package:teamxperience/ui/ui.dart';

void main() {
  for (final entry in {'light': AppTheme.light, 'dark': AppTheme.dark}.entries) {
    testWidgets('the gallery renders in ${entry.key} with the mockup copy', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(theme: entry.value, home: const ComponentGallery()));
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('4,5 km · 6 misiuni'), 300);
      expect(find.text('4,5 km · 6 misiuni'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Înscrie echipa'), 300);
      expect(find.text('Înscrie echipa'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
