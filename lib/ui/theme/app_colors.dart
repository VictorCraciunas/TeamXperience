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
    required this.onTick,
    required this.navy,
    required this.navActivePill,
    required this.iconButtonBg,
    required this.live,
    required this.soon,
    required this.success,
    required this.warning,
    required this.danger,
    required this.successSoft,
    required this.warningSoft,
    required this.dangerSoft,
    required this.onNavy,
    required this.onNavyMuted,
    required this.onNavyFaint,
    required this.tickOnNavy,
    required this.heroButton,
    required this.liveCard,
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

  /// Text and icons on a [tick] fill (dark navy, 6.5:1 on the light teal).
  final Color onTick;
  final Color navy;
  final Color navActivePill;
  final Color iconButtonBg;
  final Color live;
  final Color soon;

  /// Semantic colours for feedback (snackbars, dialogs, status banners) and
  /// their soft backgrounds.
  final Color success;
  final Color warning;
  final Color danger;
  final Color successSoft;
  final Color warningSoft;
  final Color dangerSoft;

  /// Text and icons on a [navy] fill (cards, the date tile, selected chips).
  final Color onNavy;

  /// Secondary text on a [navy] fill.
  final Color onNavyMuted;

  /// Tiles and dividers on a [navy] fill.
  final Color onNavyFaint;

  /// Teal accents on a [navy] fill (route dashes, progress).
  final Color tickOnNavy;

  /// Round buttons over a hero image (back, share).
  final Color heroButton;

  /// The live game card on Home (mockup 02's #0C092A).
  final Color liveCard;

  static const AppColors light = AppColors(
    page: Color(0xFFE7ECF3),
    panel: Color(0xFFFFFFFF),
    border: Color(0xFFCFD8E4),
    inset: Color(0xFFF3F6FA),
    insetBorder: Color(0xFFE1E7EF),
    text: Color(0xFF0C092A),
    muted: Color(0xFF47546A),
    accent: Color(0xFF167A7E),
    tick: Color(0xFF2AA5A9),
    onTick: Color(0xFF0C092A),
    navy: Color(0xFF222F62),
    navActivePill: Color(0xFFDDF3F3),
    iconButtonBg: Color(0xFFE3F2F3),
    live: Color(0xFFE5484D),
    soon: Color(0xFFF2A93B),
    success: Color(0xFF1F8F5A),
    warning: Color(0xFFB7791F),
    danger: Color(0xFFD13438),
    successSoft: Color(0xFFE2F4EA),
    warningSoft: Color(0xFFFBEFD8),
    dangerSoft: Color(0xFFFBE5E6),
    onNavy: Color(0xFFFFFFFF),
    onNavyMuted: Color(0x66FFFFFF),
    onNavyFaint: Color(0x1AFFFFFF),
    tickOnNavy: Color(0xFF53C4C7),
    heroButton: Color(0xE6FFFFFF),
    liveCard: Color(0xFF0C092A),
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
    onTick: Color(0xFF0E1116),
    navy: Color(0xFF2A3A80),
    navActivePill: Color(0xFF22393C),
    iconButtonBg: Color(0xFF232A35),
    live: Color(0xFFE5484D),
    soon: Color(0xFFF2A93B),
    success: Color(0xFF3DBE7F),
    warning: Color(0xFFE8A94B),
    danger: Color(0xFFEF6A6E),
    successSoft: Color(0xFF173226),
    warningSoft: Color(0xFF352A14),
    dangerSoft: Color(0xFF3A1B1D),
    onNavy: Color(0xFFF2F4F8),
    onNavyMuted: Color(0x66F2F4F8),
    onNavyFaint: Color(0x1AF2F4F8),
    tickOnNavy: Color(0xFF53C4C7),
    heroButton: Color(0xE6171B22),
    liveCard: Color(0xFF1B1446),
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
    Color? onTick,
    Color? navy,
    Color? navActivePill,
    Color? iconButtonBg,
    Color? live,
    Color? soon,
    Color? success,
    Color? warning,
    Color? danger,
    Color? successSoft,
    Color? warningSoft,
    Color? dangerSoft,
    Color? onNavy,
    Color? onNavyMuted,
    Color? onNavyFaint,
    Color? tickOnNavy,
    Color? heroButton,
    Color? liveCard,
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
      onTick: onTick ?? this.onTick,
      navy: navy ?? this.navy,
      navActivePill: navActivePill ?? this.navActivePill,
      iconButtonBg: iconButtonBg ?? this.iconButtonBg,
      live: live ?? this.live,
      soon: soon ?? this.soon,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      successSoft: successSoft ?? this.successSoft,
      warningSoft: warningSoft ?? this.warningSoft,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      onNavy: onNavy ?? this.onNavy,
      onNavyMuted: onNavyMuted ?? this.onNavyMuted,
      onNavyFaint: onNavyFaint ?? this.onNavyFaint,
      tickOnNavy: tickOnNavy ?? this.tickOnNavy,
      heroButton: heroButton ?? this.heroButton,
      liveCard: liveCard ?? this.liveCard,
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
      onTick: mix(onTick, other.onTick),
      navy: mix(navy, other.navy),
      navActivePill: mix(navActivePill, other.navActivePill),
      iconButtonBg: mix(iconButtonBg, other.iconButtonBg),
      live: mix(live, other.live),
      soon: mix(soon, other.soon),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      danger: mix(danger, other.danger),
      successSoft: mix(successSoft, other.successSoft),
      warningSoft: mix(warningSoft, other.warningSoft),
      dangerSoft: mix(dangerSoft, other.dangerSoft),
      onNavy: mix(onNavy, other.onNavy),
      onNavyMuted: mix(onNavyMuted, other.onNavyMuted),
      onNavyFaint: mix(onNavyFaint, other.onNavyFaint),
      tickOnNavy: mix(tickOnNavy, other.tickOnNavy),
      heroButton: mix(heroButton, other.heroButton),
      liveCard: mix(liveCard, other.liveCard),
    );
  }
}
