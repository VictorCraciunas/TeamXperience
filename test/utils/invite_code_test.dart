import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/utils/invite_code.dart';

void main() {
  group('normaliseCode', () {
    test('upper-cases and keeps only letters and digits', () {
      expect(normaliseCode('vlp-482'), 'VLP482');
      expect(normaliseCode(' vlp 482 '), 'VLP482');
      expect(normaliseCode('VLP482'), 'VLP482');
      expect(normaliseCode('---'), '');
    });
  });

  group('isWellFormedCode', () {
    test('accepts three letters then three digits, with or without a dash', () {
      expect(isWellFormedCode('VLP482'), isTrue);
      expect(isWellFormedCode('vlp-482'), isTrue);
    });

    test('rejects other shapes', () {
      expect(isWellFormedCode(''), isFalse);
      expect(isWellFormedCode('VLP48'), isFalse);
      expect(isWellFormedCode('VLP4821'), isFalse);
      expect(isWellFormedCode('VL1482'), isFalse);
      expect(isWellFormedCode('482VLP'), isFalse);
    });
  });

  group('displayCode', () {
    test('puts a dash after the letters', () {
      expect(displayCode('VLP482'), 'VLP-482');
    });
  });
}
