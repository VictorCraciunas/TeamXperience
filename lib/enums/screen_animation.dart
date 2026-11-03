/// How the components of a puzzle appear when the puzzle opens.
enum ScreenAnimation {
  /// One after another, each fading in (what the game always did).
  fade('Fade (implicit)'),

  /// All at once, with no animation.
  none('Fără animație'),

  /// One after another, each sliding in from the left and fading in.
  slideFromLeft('Slide din stânga'),
  slideFromRight('Slide din dreapta'),
  slideFromBottom('Slide de jos'),
  slideFromTop('Slide de sus'),

  /// Growing from small to full size while fading in.
  zoom('Zoom'),

  /// Coming up from below, going a little past the place and settling back.
  bounce('Bounce');

  const ScreenAnimation(this.label);

  /// The name shown in the event form.
  final String label;

  /// Reads the stored name; anything missing or unknown is [fade], so events
  /// saved before this option existed look the same as before.
  static ScreenAnimation fromName(String? name) {
    for (final animation in ScreenAnimation.values) {
      if (animation.name == name) return animation;
    }
    return ScreenAnimation.fade;
  }
}
