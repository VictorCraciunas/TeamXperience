import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

void main() {
  test('lerp at 0 returns this and at 1 returns other', () {
    expect(AppColors.light.lerp(AppColors.dark, 0), AppColors.light);
    expect(AppColors.light.lerp(AppColors.dark, 1), AppColors.dark);
  });

  test('copyWith replaces the navy-surface tokens', () {
    const x = Color(0xFF123456);
    expect(AppColors.light.copyWith(onNavy: x).onNavy, x);
    expect(AppColors.light.copyWith(heroButton: x).heroButton, x);
  });

  test('lerp mixes the navy-surface tokens', () {
    final other = AppColors.light.copyWith(tickOnNavy: const Color(0xFF000000));
    final mid = AppColors.light.lerp(other, 0.5);
    expect(mid.tickOnNavy, Color.lerp(AppColors.light.tickOnNavy, const Color(0xFF000000), 0.5));
  });
}
