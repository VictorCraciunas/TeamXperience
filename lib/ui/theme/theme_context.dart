import 'package:flutter/material.dart';

import 'app_colors.dart';

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
