/// A movement a component repeats for as long as the puzzle is open.
enum LoopEffect {
  /// Grows a little and comes back.
  pulse('Pulse', Duration(milliseconds: 1600)),

  /// Rises a little and comes back.
  float('Float', Duration(milliseconds: 1600)),

  /// A short shake left and right, then a pause.
  shake('Shake', Duration(milliseconds: 2000)),

  /// Dims and comes back, like a faulty light.
  flicker('Flicker', Duration(milliseconds: 1400)),

  /// Still, then a quick jump sideways, now and then.
  glitch('Glitch', Duration(milliseconds: 2200));

  const LoopEffect(this.label, this.cycle);

  /// The name shown in the editor.
  final String label;

  /// How long one round takes.
  final Duration cycle;

  /// Reads the stored name; anything missing or unknown is no effect.
  static LoopEffect? fromName(String? name) {
    for (final effect in LoopEffect.values) {
      if (effect.name == name) return effect;
    }
    return null;
  }
}
