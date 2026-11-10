import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'contrast.dart';

/// Font families shared by the event screens.
abstract class AppFonts {
  /// The serif of letters and stories (metric-compatible with Georgia).
  static const String voice = 'Gelasio';
}

/// The colours an event's own screens use, from the intro onwards. Each
/// event's comes from its own puzzles (`eventPaletteOf` in the game feature);
/// an event whose puzzles set nothing gets [EventPalette.fromApp].
@immutable
class EventPalette {
  const EventPalette({
    required this.background,
    required this.surface,
    required this.border,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.onAccent,
    required this.secondaryAccent,
    required this.danger,
    required this.routeDash,
    this.voiceFont = AppFonts.voice,
    this.backgroundImage,
  });

  final Color background;
  final Color surface;
  final Color border;
  final Color ink;
  final Color muted;

  /// Text quieter than [muted] (dates, footnotes).
  final Color faint;
  final Color accent;

  /// Text and icons on [accent] fills.
  final Color onAccent;

  /// The second accent (gold in parchment).
  final Color secondaryAccent;
  final Color danger;

  /// The dashes of the route line.
  final Color routeDash;
  final String voiceFont;

  /// The picture the event's puzzles are drawn on, shown behind the route.
  final ImageProvider? backgroundImage;

  /// The old-map look of mockups 05 to 08: the reference the sample event's
  /// puzzles are built to match. Organisers never pick it; it is what an event
  /// with these colours in its puzzles resolves to.
  static const EventPalette parchment = EventPalette(
    background: Color(0xFFEADBC0),
    surface: Color(0xFFFBF4E4),
    border: Color(0xFFD9C49C),
    ink: Color(0xFF3B2A1A),
    muted: Color(0xFF5E4426),
    faint: Color(0xFF8C6A44),
    accent: Color(0xFF8A3B12),
    onAccent: Color(0xFFFBF4E4),
    secondaryAccent: Color(0xFFB8862B),
    danger: Color(0xFFA3262A),
    routeDash: Color(0xFFC9B48E),
  );

  /// The app's own colours, for events whose puzzles set none.
  factory EventPalette.fromApp(AppColors c, {ImageProvider? backgroundImage}) => EventPalette(
        background: c.page,
        surface: c.panel,
        border: c.border,
        ink: c.text,
        muted: c.muted,
        faint: c.muted,
        accent: c.accent,
        onAccent: readableOn([c.accent]),
        secondaryAccent: c.soon,
        danger: c.danger,
        routeDash: c.tick,
        backgroundImage: backgroundImage,
      );

  @override
  bool operator ==(Object other) =>
      other is EventPalette &&
      other.background == background &&
      other.surface == surface &&
      other.border == border &&
      other.ink == ink &&
      other.muted == muted &&
      other.faint == faint &&
      other.accent == accent &&
      other.onAccent == onAccent &&
      other.secondaryAccent == secondaryAccent &&
      other.danger == danger &&
      other.routeDash == routeDash &&
      other.voiceFont == voiceFont &&
      other.backgroundImage == backgroundImage;

  @override
  int get hashCode => Object.hash(background, surface, border, ink, muted, faint, accent, onAccent,
      secondaryAccent, danger, routeDash, voiceFont, backgroundImage);
}
