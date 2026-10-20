import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/theme/app_spacing.dart';

void main() {
  test('the spacing scale has the agreed values', () {
    expect(
      [AppSpacing.xs, AppSpacing.sm, AppSpacing.md, AppSpacing.lg, AppSpacing.xl],
      [4, 8, 12, 16, 24],
    );
  });

  test('screens use a 16 px side padding', () {
    expect(AppSpacing.page, 16);
  });
}
