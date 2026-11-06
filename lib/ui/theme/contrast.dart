import 'dart:math' as math;
import 'dart:ui';

/// Near-black and near-white, for text the event's own colours cannot carry.
const Color guardDark = Color(0xFF1A1410);
const Color guardLight = Color(0xFFF7F2E8);

/// The WCAG contrast ratio of two opaque colours, from 1 (the same) to 21.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// [guardDark] or [guardLight], whichever reads better on every one of
/// [backgrounds] (the one whose worst contrast is higher).
Color readableOn(List<Color> backgrounds) {
  double worst(Color text) => backgrounds.map((b) => contrastRatio(text, b)).reduce(math.min);
  return worst(guardDark) >= worst(guardLight) ? guardDark : guardLight;
}
