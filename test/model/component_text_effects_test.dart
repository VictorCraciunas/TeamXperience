import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

void main() {
  test('none of the options is written unless set', () {
    final json = Component(type: ComponentType.text, text: 'x').toJson();
    for (final key in ['lineHeight', 'italic', 'uppercase', 'shadowColor', 'shadowBlur', 'shadowDistance']) {
      expect(json.containsKey(key), isFalse, reason: key);
    }
  });

  test('the options are written and read back', () {
    final component = Component(
      type: ComponentType.text,
      lineHeight: 1.4,
      italic: true,
      uppercase: false,
      shadowColor: '#112233',
      shadowBlur: 6.5,
      shadowDistance: 3,
    );
    final back = Component.fromMap(component.toJson());
    expect(back.lineHeight, 1.4);
    expect(back.italic, isTrue);
    expect(back.uppercase, isFalse);
    expect(back.shadowColor, '#112233');
    expect(back.shadowBlur, 6.5);
    expect(back.shadowDistance, 3.0);
  });

  test('zero and false are real values', () {
    final back = Component.fromMap(Component(type: ComponentType.text, shadowBlur: 0, shadowDistance: 0, italic: false).toJson());
    expect(back.shadowBlur, 0.0);
    expect(back.shadowDistance, 0.0);
    expect(back.italic, isFalse);
  });

  test('whole numbers from the database are read as decimals', () {
    final back = Component.fromMap({'type': 'text', 'lineHeight': 2, 'shadowBlur': 5, 'shadowDistance': 4});
    expect(back.lineHeight, 2.0);
    expect(back.shadowBlur, 5.0);
    expect(back.shadowDistance, 4.0);
  });

  test('texts saved before the options existed still load', () {
    final back = Component.fromMap({'type': 'text', 'text': 'x'});
    expect(back.lineHeight, isNull);
    expect(back.italic, isNull);
    expect(back.shadowColor, isNull);
  });
}
