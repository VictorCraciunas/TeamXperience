/// How the components of a puzzle appear when the puzzle opens.
enum ScreenAnimation {
  /// One after another, each fading in (what the game always did).
  fade('Fade (implicit)'),

  /// All at once, with no animation.
  none('Fără animație');

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
