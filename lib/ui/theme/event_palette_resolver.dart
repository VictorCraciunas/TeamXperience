import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'app_colors.dart';
import 'contrast.dart';
import 'event_palette.dart';

export 'contrast.dart' show contrastRatio;

/// What an event's own puzzles already use, already chosen: the most common
/// value across its components, else the event's component defaults. Null
/// where neither says anything. Built by `styleHintsFrom` in the game feature.
@immutable
class StyleHints {
  const StyleHints({this.accent, this.ink, this.surface, this.background, this.glow, this.font});

  final Color? accent;
  final Color? ink;
  final Color? surface;
  final Color? background;
  final Color? glow;

  /// A font family name ("Gelasio").
  final String? font;

  bool get isEmpty =>
      accent == null && ink == null && surface == null && background == null && glow == null && font == null;
}

/// The glow as the second accent when it shows on the surface (2:1: it only
/// marks the current mission's bar and card; the mockup's gold is 2.9:1),
/// else the accent, softer.
Color _secondAccent(Color? glow, Color accent, Color surface) {
  if (glow != null && contrastRatio(glow, surface) >= 2) return glow;
  return accent.withValues(alpha: .55);
}

/// The colours of an event's game screens: what its puzzles use, else the
/// app's. Text the puzzles' colours would make unreadable is replaced by
/// near-black or near-white.
EventPalette resolveEventPalette({
  required StyleHints hints,
  required AppColors app,
  ImageProvider? backgroundImage,
}) {
  final fromApp = EventPalette.fromApp(app, backgroundImage: backgroundImage);
  if (hints.isEmpty) return fromApp;

  final background = hints.background ?? app.page;
  var surface = hints.surface ?? app.panel;

  bool readsOnBoth(Color text) => contrastRatio(text, background) >= 4.5 && contrastRatio(text, surface) >= 4.5;
  final wanted = hints.ink ?? app.text;
  var ink = wanted;
  if (!readsOnBoth(ink)) ink = readableOn([background, surface]);
  if (!readsOnBoth(ink)) {
    // The page and the surface need opposite text: the page wins, and the
    // surface becomes a tint of it.
    ink = contrastRatio(wanted, background) >= 4.5 ? wanted : readableOn([background]);
    surface = Color.alphaBlend(ink.withValues(alpha: .06), background);
  }

  var accent = hints.accent ?? app.accent;
  if (contrastRatio(accent, surface) < 3) {
    accent = contrastRatio(app.accent, surface) >= 3 ? app.accent : ink;
  }

  return EventPalette(
    background: background,
    surface: surface,
    border: ink.withValues(alpha: .25),
    ink: ink,
    muted: ink.withValues(alpha: .75),
    faint: ink.withValues(alpha: .55),
    accent: accent,
    onAccent: readableOn([accent]),
    secondaryAccent: _secondAccent(hints.glow, accent, surface),
    danger: app.danger,
    routeDash: ink.withValues(alpha: .3),
    voiceFont: hints.font ?? AppFonts.voice,
    backgroundImage: backgroundImage,
  );
}
