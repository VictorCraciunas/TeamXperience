class TeamMember {
  final String uid;
  final String displayName;
  final String initials;

  const TeamMember({
    required this.uid,
    required this.displayName,
    required this.initials,
  });

  /// A member known only by name (old teams): no uid, initials from the
  /// first letters of the first two words.
  factory TeamMember.fromName(String name) {
    final trimmed = name.trim();
    final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final initials = words
        .take(2)
        .map((w) => String.fromCharCode(w.runes.first).toUpperCase())
        .join();
    return TeamMember(uid: '', displayName: trimmed, initials: initials);
  }

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      uid: map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      initials: map['initials'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'initials': initials,
    };
  }
}
