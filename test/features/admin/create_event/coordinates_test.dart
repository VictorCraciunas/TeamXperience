import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/create_event/logic/coordinates.dart';

void main() {
  test('reads what Google Maps copies', () {
    for (final text in ['45.7971, 24.1520', '45.7971,24.1520', '45.7971 24.1520', ' 45.7971 ,  24.1520 ']) {
      final c = parseCoordinates(text);
      expect(c?.lat, 45.7971, reason: text);
      expect(c?.lng, 24.152, reason: text);
    }
  });

  test('negative coordinates are fine', () {
    expect(parseCoordinates('-33.8688, 151.2093')?.lat, -33.8688);
  });

  test('empty, a single number or out of range gives null', () {
    expect(parseCoordinates(''), isNull);
    expect(parseCoordinates('45.79'), isNull);
    expect(parseCoordinates('91, 24'), isNull);
    expect(parseCoordinates('45, 181'), isNull);
    expect(parseCoordinates('Piața Mare'), isNull);
  });

  test('written back with four decimals', () {
    expect(formatCoordinates(45.7971, 24.152), '45.7971, 24.1520');
  });
}
