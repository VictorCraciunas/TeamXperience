import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

void main() {
  test('none of the options is set unless asked, and none is written', () {
    final json = Component(type: ComponentType.button).toJson();
    for (final key in ['letterSpacing', 'paddingY', 'boxHeight', 'boldText', 'glowOn']) {
      expect(json.containsKey(key), isFalse, reason: key);
    }
  });

  test('the options are written and read back', () {
    final component = Component(
      type: ComponentType.code,
      letterSpacing: 3.5,
      paddingY: 12,
      boxHeight: 64,
      boldText: false,
      glowOn: 'boxes',
    );
    final back = Component.fromMap(component.toJson());
    expect(back.letterSpacing, 3.5);
    expect(back.paddingY, 12.0);
    expect(back.boxHeight, 64.0);
    expect(back.boldText, isFalse);
    expect(back.glowOn, 'boxes');
  });

  test('zero and false are real values', () {
    final back = Component.fromMap(Component(type: ComponentType.button, letterSpacing: 0, paddingY: 0, boldText: false).toJson());
    expect(back.letterSpacing, 0.0);
    expect(back.paddingY, 0.0);
    expect(back.boldText, isFalse);
  });

  test('whole numbers saved in the database are read as decimals', () {
    final back = Component.fromMap({'type': 'code', 'letterSpacing': 4, 'paddingY': 9, 'boxHeight': 50});
    expect(back.letterSpacing, 4.0);
    expect(back.paddingY, 9.0);
    expect(back.boxHeight, 50.0);
  });

  test('components saved before the options existed still load', () {
    final back = Component.fromMap({'type': 'code', 'codeLength': 4});
    expect(back.letterSpacing, isNull);
    expect(back.boldText, isNull);
    expect(back.glowOn, isNull);
  });
}
