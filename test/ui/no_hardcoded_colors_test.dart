import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Screens read colours from the theme. Files that still contain literal
/// colours (white over photos, map markers, admin puzzle colours, brand
/// colours) are listed with their current count in `colour_allowlist.txt`.
/// A file may never gain colours, and a new file may not have any.
void main() {
  final pattern = RegExp(r'Color\(0x|Colors\.');

  Map<String, int> allowed() {
    final map = <String, int>{};
    for (final line in File('test/ui/colour_allowlist.txt').readAsLinesSync()) {
      final parts = line.trim().split(' ');
      if (parts.length == 2) map[parts[0]] = int.parse(parts[1]);
    }
    return map;
  }

  test('features do not add hardcoded colours', () {
    final allow = allowed();
    final problems = <String>[];

    final files = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final path = file.path.replaceAll(r'\', '/');
      final count = pattern.allMatches(file.readAsStringSync()).length;
      final limit = allow[path] ?? 0;
      if (count > limit) {
        problems.add('$path has $count literal colours (allowed $limit)');
      }
    }

    expect(problems, isEmpty, reason: 'Use context.colors tokens instead:\n${problems.join('\n')}');
  });

  test('the allow-list only names files that exist', () {
    final missing = allowed().keys.where((p) => !File(p).existsSync()).toList();
    expect(missing, isEmpty);
  });
}
