/// How hard an event is, shown as dots on the event page.
enum Difficulty {
  easy,
  medium,
  hard;

  /// Reads the stored name; anything missing or unknown is null.
  static Difficulty? fromName(String? name) {
    for (final difficulty in Difficulty.values) {
      if (difficulty.name == name) return difficulty;
    }
    return null;
  }
}
