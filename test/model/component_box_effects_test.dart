import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

void main() {
  test('neither option is written unless set', () {
    final json = Component(type: ComponentType.image).toJson();
    expect(json.containsKey('opacity'), isFalse);
    expect(json.containsKey('borderWidth'), isFalse);
  });

  test('both are written and read back', () {
    final back = Component.fromMap(Component(type: ComponentType.image, opacity: 0.4, borderWidth: 3.5).toJson());
    expect(back.opacity, 0.4);
    expect(back.borderWidth, 3.5);
  });

  test('zero is a real value', () {
    final back = Component.fromMap(Component(type: ComponentType.button, opacity: 0, borderWidth: 0).toJson());
    expect(back.opacity, 0.0);
    expect(back.borderWidth, 0.0);
  });

  test('whole numbers from the database are read as decimals', () {
    final back = Component.fromMap({'type': 'image', 'opacity': 1, 'borderWidth': 2});
    expect(back.opacity, 1.0);
    expect(back.borderWidth, 2.0);
  });

  test('components saved before the options existed still load', () {
    final back = Component.fromMap({'type': 'image'});
    expect(back.opacity, isNull);
    expect(back.borderWidth, isNull);
  });
}
