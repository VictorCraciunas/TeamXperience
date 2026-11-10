/// What the players thought of the event: the stars they gave at the finish.
class RatingSummary {
  const RatingSummary({required this.count, required this.average, required this.byStars});

  /// How many players rated.
  final int count;

  /// Null when nobody rated yet.
  final double? average;

  /// How many gave 1, 2, 3, 4 and 5 stars, in that order.
  final List<int> byStars;

  /// How many gave [stars] (1–5).
  int of(int stars) => byStars[stars - 1];
}

/// Sums up the ratings; anything outside 1–5 is left out.
RatingSummary ratingSummary(Iterable<int> ratings) {
  final byStars = List<int>.filled(5, 0);
  var count = 0;
  var total = 0;
  for (final r in ratings) {
    if (r < 1 || r > 5) continue;
    byStars[r - 1]++;
    count++;
    total += r;
  }
  return RatingSummary(count: count, average: count == 0 ? null : total / count, byStars: byStars);
}
