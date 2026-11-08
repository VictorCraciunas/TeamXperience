/// A player's totals over every game, written by the end-of-event function
/// (step 7c); zero until then.
class UserStats {
  const UserStats({this.games = 0, this.distanceMeters = 0, this.missions = 0, this.podiums = 0});

  final int games;
  final double distanceMeters;
  final int missions;

  /// Games finished in the first three places.
  final int podiums;

  static int _count(Object? value) => value is num ? value.toInt() : 0;

  factory UserStats.fromMap(Object? raw) {
    if (raw is! Map) return const UserStats();
    final km = raw['distanceMeters'];
    return UserStats(
      games: _count(raw['games']),
      distanceMeters: km is num ? km.toDouble() : 0,
      missions: _count(raw['missions']),
      podiums: _count(raw['podiums']),
    );
  }

  Map<String, dynamic> toJson() =>
      {'games': games, 'distanceMeters': distanceMeters, 'missions': missions, 'podiums': podiums};
}
