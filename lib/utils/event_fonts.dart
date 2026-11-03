import 'dart:ui';

/// A font an event can use. [family] is the name written in an event and in
/// `pubspec.yaml`.
class EventFont {
  const EventFont(
    this.family,
    this.files, {
    this.variable = false,
    this.minWeight = 400,
    this.maxWeight = 400,
    this.licence,
  });

  final String family;

  /// The font files in `assets/fonts`.
  final List<String> files;

  /// True when one file holds every weight, set with a `wght` variation.
  final bool variable;
  final double minWeight;
  final double maxWeight;

  /// The licence text in `assets/fonts/licenses`, for fonts added after the first two.
  final String? licence;
}

/// Every font of the app, in the order the editors list them. The first two are
/// the ones the app always had.
const eventFonts = <EventFont>[
  EventFont('Poppins', [
    'assets/fonts/Poppins-Light.ttf',
    'assets/fonts/Poppins-Regular.ttf',
    'assets/fonts/Poppins-Medium.ttf',
    'assets/fonts/Poppins-SemiBold.ttf',
    'assets/fonts/Poppins-Bold.ttf',
    'assets/fonts/Poppins-ExtraBold.ttf',
  ]),
  EventFont('Monospace', ['assets/fonts/SpaceMono-Regular.ttf', 'assets/fonts/SpaceMono-Bold.ttf']),
  EventFont(
    'Orbitron',
    ['assets/fonts/Orbitron-Variable.ttf'],
    variable: true,
    minWeight: 400,
    maxWeight: 900,
    licence: 'Orbitron-OFL.txt',
  ),
  EventFont('Share Tech Mono', ['assets/fonts/ShareTechMono-Regular.ttf'], licence: 'ShareTechMono-OFL.txt'),
  EventFont('Press Start 2P', ['assets/fonts/PressStart2P-Regular.ttf'], licence: 'PressStart2P-OFL.txt'),
  EventFont(
    'Cinzel',
    ['assets/fonts/Cinzel-Variable.ttf'],
    variable: true,
    minWeight: 400,
    maxWeight: 900,
    licence: 'Cinzel-OFL.txt',
  ),
  EventFont('Special Elite', ['assets/fonts/SpecialElite-Regular.ttf'], licence: 'SpecialElite-Apache-LICENSE.txt'),
  EventFont(
    'Caveat',
    ['assets/fonts/Caveat-Variable.ttf'],
    variable: true,
    minWeight: 400,
    maxWeight: 700,
    licence: 'Caveat-OFL.txt',
  ),
  EventFont('Bebas Neue', ['assets/fonts/BebasNeue-Regular.ttf'], licence: 'BebasNeue-OFL.txt'),
  EventFont(
    'Playfair Display',
    ['assets/fonts/PlayfairDisplay-Variable.ttf'],
    variable: true,
    minWeight: 400,
    maxWeight: 900,
    licence: 'PlayfairDisplay-OFL.txt',
  ),
  // The serif of event letters and stories (AppFonts.voice), metric-compatible with Georgia.
  EventFont(
    'Gelasio',
    ['assets/fonts/Gelasio-Variable.ttf'],
    variable: true,
    minWeight: 400,
    maxWeight: 700,
    licence: 'Gelasio-OFL.txt',
  ),
];

/// The names of the fonts, as written in an event.
final List<String> eventFontNames = [for (final font in eventFonts) font.family];

bool isEventFont(String? family) => eventFontNames.contains(family);

/// The `wght` variation for [family] at [weight], or null when the font is not
/// a variable one. A weight the font does not have is moved to the nearest it has.
List<FontVariation>? fontVariationsFor(String? family, FontWeight weight) {
  for (final font in eventFonts) {
    if (font.family != family || !font.variable) continue;

    final value = weight.value.toDouble().clamp(font.minWeight, font.maxWeight).toDouble();
    return [FontVariation('wght', value)];
  }
  return null;
}
