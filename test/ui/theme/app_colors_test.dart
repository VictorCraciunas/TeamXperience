import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

void main() {
  test('light tokens match spec', () {
    expect(AppColors.light.page, const Color(0xFFE7ECF3));
    expect(AppColors.light.panel, const Color(0xFFFFFFFF));
    expect(AppColors.light.text, const Color(0xFF0C092A));
    expect(AppColors.light.accent, const Color(0xFF167A7E));
  });

  test('dark tokens match spec', () {
    expect(AppColors.dark.page, const Color(0xFF0E1116));
    expect(AppColors.dark.panel, const Color(0xFF171B22));
    expect(AppColors.dark.accent, const Color(0xFF5CC8CB));
  });

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

  test('navy-surface tokens match the mockups', () {
    expect(AppColors.light.onNavy, const Color(0xFFFFFFFF));
    expect(AppColors.light.onNavyMuted, const Color(0x66FFFFFF));
    expect(AppColors.light.onNavyFaint, const Color(0x1AFFFFFF));
    expect(AppColors.light.tickOnNavy, const Color(0xFF53C4C7));
    expect(AppColors.light.heroButton, const Color(0xE6FFFFFF));
    expect(AppColors.dark.onNavy, const Color(0xFFF2F4F8));
    expect(AppColors.dark.heroButton, const Color(0xE6171B22));
  });
}
