import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'theme_context.dart';

/// The text styles of the approved screens. They read colours from the active
/// theme and leave the font family to the theme (Poppins).
abstract class AppTextStyles {
  static TextStyle headline(BuildContext c) => _headline(c.colors);
  static TextStyle sectionTitle(BuildContext c) => _sectionTitle(c.colors);
  static TextStyle title(BuildContext c) => _title(c.colors);
  static TextStyle body(BuildContext c) => _body(c.colors);
  static TextStyle bodyMuted(BuildContext c) => _bodyMuted(c.colors);
  static TextStyle caption(BuildContext c) => _caption(c.colors);
  static TextStyle label(BuildContext c) => _label(c.colors);
  static TextStyle button(BuildContext c) => _button(c.colors);
  static TextStyle wordmark(BuildContext c) => _wordmark(c.colors);

  /// The styles of the November 2026 mockups (docs/roadmap/mockups), at their
  /// exact CSS sizes.
  static TextStyle heroTitle(BuildContext c) => _heroTitle(c.colors);
  static TextStyle trailHeading(BuildContext c) => _trailHeading(c.colors);
  static TextStyle cardTitle(BuildContext c) => _cardTitle(c.colors);
  static TextStyle pageBody(BuildContext c) => _pageBody(c.colors);
  static TextStyle smallMuted(BuildContext c) => _smallMuted(c.colors);
  static TextStyle factValue(BuildContext c) => _factValue(c.colors);
  static TextStyle display(BuildContext c) => _display(c.colors);

  /// The same set as a [TextTheme], registered in `AppTheme`.
  static TextTheme textTheme(AppColors colors) {
    return TextTheme(
      headlineSmall: _headline(colors),
      titleMedium: _sectionTitle(colors),
      titleSmall: _title(colors),
      bodyMedium: _body(colors),
      bodySmall: _caption(colors),
      labelLarge: _button(colors),
      labelMedium: _label(colors),
    );
  }

  static TextStyle _headline(AppColors c) =>
      TextStyle(color: c.text, fontSize: 22, fontWeight: FontWeight.w700);

  static TextStyle _sectionTitle(AppColors c) =>
      TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w600);

  static TextStyle _title(AppColors c) =>
      TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600);

  static TextStyle _body(AppColors c) =>
      TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w400);

  static TextStyle _bodyMuted(AppColors c) =>
      TextStyle(color: c.muted, fontSize: 13, fontWeight: FontWeight.w400);

  static TextStyle _caption(AppColors c) =>
      TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w400);

  static TextStyle _label(AppColors c) =>
      TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600);

  static TextStyle _button(AppColors c) =>
      TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600);

  static TextStyle _wordmark(AppColors c) =>
      TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.w700);

  static TextStyle _heroTitle(AppColors c) =>
      TextStyle(color: c.text, fontSize: 19, fontWeight: FontWeight.w500, height: 1.2);

  static TextStyle _trailHeading(AppColors c) =>
      TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle _cardTitle(AppColors c) =>
      TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w500);

  static TextStyle _pageBody(AppColors c) =>
      TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w400, height: 1.45);

  static TextStyle _smallMuted(AppColors c) =>
      TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w400, height: 1.45);

  static TextStyle _factValue(AppColors c) =>
      TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.w500, height: 1.0);

  static TextStyle _display(AppColors c) =>
      TextStyle(color: c.text, fontSize: 34, fontWeight: FontWeight.w500, height: 1.0);
}
