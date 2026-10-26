import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

void main() {
  test('a component has no space below set unless asked', () {
    final component = Component(type: ComponentType.text, text: 'x');
    expect(component.spaceBelow, isNull);
    expect(component.toJson().containsKey('spaceBelow'), isFalse);
  });

  test('the space below is written and read back', () {
    final component = Component(type: ComponentType.text, spaceBelow: 12.5);
    final back = Component.fromMap(component.toJson());
    expect(back.spaceBelow, 12.5);
  });

  test('zero is a real value, not "not set"', () {
    final component = Component(type: ComponentType.text, spaceBelow: 0);
    expect(component.toJson()['spaceBelow'], 0.0);
    expect(Component.fromMap(component.toJson()).spaceBelow, 0.0);
  });

  test('a whole number saved in the database is read as a decimal', () {
    final component = Component.fromMap({'type': 'text', 'spaceBelow': 24});
    expect(component.spaceBelow, 24.0);
  });

  test('components saved before the option existed still load', () {
    final component = Component.fromMap({'type': 'button', 'buttonLabel': 'x'});
    expect(component.spaceBelow, isNull);
  });
}
