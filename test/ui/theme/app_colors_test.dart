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
}
