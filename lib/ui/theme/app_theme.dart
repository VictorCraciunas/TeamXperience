import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: colors.tick,
      brightness: brightness,
    ).copyWith(
      primary: colors.accent,
      onPrimary: isLight ? Colors.white : colors.page,
      surface: colors.panel,
      onSurface: colors.text,
      outline: colors.border,
      error: colors.live,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Poppins',
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.page,
      canvasColor: colors.panel,
      dialogTheme: DialogThemeData(
        backgroundColor: colors.panel,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.panel,
        modalBackgroundColor: colors.panel,
        surfaceTintColor: Colors.transparent,
      ),
      extensions: [colors],
    );
  }
}
