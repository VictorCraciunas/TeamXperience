import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/pin_field_button.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/pin_picker_screen.dart';
import 'package:teamxperience/features/admin/create_event/logic/coordinates.dart';

import '../../../ui/pump_ui.dart';

void main() {
  group('pinStart', () {
    const a = (lat: 1.0, lng: 2.0);
    const b = (lat: 3.0, lng: 4.0);
    test('the place already set', () => expect(pinStart(a, b), a));
    test('else somewhere near', () => expect(pinStart(null, b), b));
    test('else Sibiu', () => expect(pinStart(null, null), defaultPlace));
  });

  group('PinFieldButton', () {
    Future<(List<MapPlace>, List<(MapPlace?, MapPlace?)>)> open(
      WidgetTester tester, {
      MapPlace? current,
      MapPlace? near,
      MapPlace? answer,
    }) async {
      final picked = <MapPlace>[];
      final opened = <(MapPlace?, MapPlace?)>[];
      await pumpUi(
        tester,
        PinFieldButton(
          current: () => current,
          near: near,
          onPicked: picked.add,
          picker: (context, initial, nearby) async {
            opened.add((initial, nearby));
            return answer;
          },
        ),
      );
      await tester.tap(find.text('Alege pe hartă'));
      await tester.pump();
      return (picked, opened);
    }

    testWidgets('opens on the place in the field, and reports the new one', (tester) async {
      final (picked, opened) = await open(
        tester,
        current: (lat: 1.0, lng: 2.0),
        answer: (lat: 5.0, lng: 6.0),
      );
      expect(opened.single.$1, (lat: 1.0, lng: 2.0));
      expect(picked.single, (lat: 5.0, lng: 6.0));
    });

    testWidgets('a field it cannot read opens with no pin, from somewhere near', (tester) async {
      final (_, opened) = await open(tester, near: (lat: 3.0, lng: 4.0));
      expect(opened.single, (null, (lat: 3.0, lng: 4.0)));
    });

    testWidgets('cancelling reports nothing', (tester) async {
      final (picked, _) = await open(tester, current: (lat: 1.0, lng: 2.0));
      expect(picked, isEmpty);
    });
  });
}
