import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

double _channel(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) => 0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const themes = {'light': AppColors.light, 'dark': AppColors.dark};

  for (final entry in themes.entries) {
    final c = entry.value;
    final name = entry.key;

    test('$name: text and muted are readable on page and panel', () {
      expect(contrast(c.text, c.page), greaterThanOrEqualTo(4.5));
      expect(contrast(c.text, c.panel), greaterThanOrEqualTo(4.5));
      expect(contrast(c.muted, c.page), greaterThanOrEqualTo(4.5));
      expect(contrast(c.muted, c.panel), greaterThanOrEqualTo(4.5));
      expect(contrast(c.muted, c.inset), greaterThanOrEqualTo(4.5));
    });

    test('$name: links in the accent colour are readable on panels', () {
      expect(contrast(c.accent, c.panel), greaterThanOrEqualTo(4.5));
    });

    test('$name: text on a tick fill is readable', () {
      expect(contrast(c.onTick, c.tick), greaterThanOrEqualTo(4.5));
    });

    test('$name: text and teal accents on navy are readable', () {
      expect(contrast(c.onNavy, c.navy), greaterThanOrEqualTo(4.5));
      expect(contrast(c.tickOnNavy, c.navy), greaterThanOrEqualTo(3));
    });

    test('$name: feedback colours are readable on their soft backgrounds', () {
      expect(contrast(c.success, c.successSoft), greaterThanOrEqualTo(3));
      expect(contrast(c.warning, c.warningSoft), greaterThanOrEqualTo(3));
      expect(contrast(c.danger, c.dangerSoft), greaterThanOrEqualTo(3));
    });
  }
}
