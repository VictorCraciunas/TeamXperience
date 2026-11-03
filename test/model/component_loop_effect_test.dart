import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/loop_effect.dart';
import 'package:teamxperience/model/component.dart';

void main() {
  test('no effect is written unless one was chosen', () {
    expect(Component(type: ComponentType.text).toJson().containsKey('loopEffect'), isFalse);
  });

  test('every effect is written and read back', () {
    for (final effect in LoopEffect.values) {
      final back = Component.fromMap(Component(type: ComponentType.button, loopEffect: effect).toJson());
      expect(back.loopEffect, effect);
    }
  });

  test('written by its name', () {
    expect(Component(type: ComponentType.text, loopEffect: LoopEffect.glitch).toJson()['loopEffect'], 'glitch');
  });

  test('a name the app does not know is no effect, not a crash', () {
    expect(Component.fromMap({'type': 'text', 'loopEffect': 'spin'}).loopEffect, isNull);
  });

  test('components saved before the option existed still load', () {
    expect(Component.fromMap({'type': 'text'}).loopEffect, isNull);
  });
}
