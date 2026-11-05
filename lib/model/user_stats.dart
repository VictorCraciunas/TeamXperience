/// A player's totals over every game, written by the end-of-event function
/// (step 7); zero until then.
class UserStats {
  const UserStats({this.games = 0, this.distanceMeters = 0});

  final int games;
  final double distanceMeters;

  factory UserStats.fromMap(Object? raw) {
    if (raw is! Map) return const UserStats();
    return UserStats(
      games: (raw['games'] as num?)?.toInt() ?? 0,
      distanceMeters: (raw['distanceMeters'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'games': games, 'distanceMeters': distanceMeters};
}
