import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

void main() {
  test('is not written unless set', () {
    expect(Component(type: ComponentType.code).toJson().containsKey('answerFeedback'), isFalse);
  });

  test('false is written and read back, so it can be switched off', () {
    final back = Component.fromMap(Component(type: ComponentType.code, answerFeedback: false).toJson());
    expect(back.answerFeedback, isFalse);
  });

  test('true is written and read back', () {
    expect(Component.fromMap(Component(type: ComponentType.code, answerFeedback: true).toJson()).answerFeedback, isTrue);
  });

  test('components saved before the option existed have none set', () {
    expect(Component.fromMap({'type': 'code'}).answerFeedback, isNull);
  });
}
