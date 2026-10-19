import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.page,
    required this.panel,
    required this.border,
    required this.inset,
    required this.insetBorder,
    required this.text,
    required this.muted,
    required this.accent,
    required this.tick,
    required this.navy,
    required this.navActivePill,
    required this.iconButtonBg,
    required this.live,
    required this.soon,
  });

  final Color page;
  final Color panel;
  final Color border;
  final Color inset;
  final Color insetBorder;
  final Color text;
  final Color muted;
  final Color accent;
  final Color tick;
  final Color navy;
  final Color navActivePill;
  final Color iconButtonBg;
  final Color live;
  final Color soon;

  static const AppColors light = AppColors(
    page: Color(0xFFE7ECF3),
    panel: Color(0xFFFFFFFF),
    border: Color(0xFFCFD8E4),
    inset: Color(0xFFF3F6FA),
    insetBorder: Color(0xFFE1E7EF),
    text: Color(0xFF0C092A),
    muted: Color(0xFF47546A),
    accent: Color(0xFF1B8A8E),
    tick: Color(0xFF2AA5A9),
    navy: Color(0xFF222F62),
    navActivePill: Color(0xFFDDF3F3),
    iconButtonBg: Color(0xFFE3F2F3),
    live: Color(0xFFE5484D),
    soon: Color(0xFFF2A93B),
  );

  static const AppColors dark = AppColors(
    page: Color(0xFF0E1116),
    panel: Color(0xFF171B22),
    border: Color(0xFF2A303B),
    inset: Color(0xFF11151B),
    insetBorder: Color(0xFF252B35),
    text: Color(0xFFF2F4F8),
    muted: Color(0xFFA3ACBB),
    accent: Color(0xFF5CC8CB),
    tick: Color(0xFF53C4C7),
    navy: Color(0xFF2A3A80),
    navActivePill: Color(0xFF22393C),
    iconButtonBg: Color(0xFF232A35),
    live: Color(0xFFE5484D),
    soon: Color(0xFFF2A93B),
  );

  LinearGradient get ctaGradient => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF2AA5A9), Color(0xFF222F62)],
      );

  @override
  AppColors copyWith({
    Color? page,
    Color? panel,
    Color? border,
    Color? inset,
    Color? insetBorder,
    Color? text,
    Color? muted,
    Color? accent,
    Color? tick,
    Color? navy,
    Color? navActivePill,
    Color? iconButtonBg,
    Color? live,
    Color? soon,
  }) {
    return AppColors(
      page: page ?? this.page,
      panel: panel ?? this.panel,
      border: border ?? this.border,
      inset: inset ?? this.inset,
      insetBorder: insetBorder ?? this.insetBorder,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      tick: tick ?? this.tick,
      navy: navy ?? this.navy,
      navActivePill: navActivePill ?? this.navActivePill,
      iconButtonBg: iconButtonBg ?? this.iconButtonBg,
      live: live ?? this.live,
      soon: soon ?? this.soon,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors || t <= 0) return this;
    if (t >= 1) return other;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppColors(
      page: mix(page, other.page),
      panel: mix(panel, other.panel),
      border: mix(border, other.border),
      inset: mix(inset, other.inset),
      insetBorder: mix(insetBorder, other.insetBorder),
      text: mix(text, other.text),
      muted: mix(muted, other.muted),
      accent: mix(accent, other.accent),
      tick: mix(tick, other.tick),
      navy: mix(navy, other.navy),
      navActivePill: mix(navActivePill, other.navActivePill),
      iconButtonBg: mix(iconButtonBg, other.iconButtonBg),
      live: mix(live, other.live),
      soon: mix(soon, other.soon),
    );
  }
}
