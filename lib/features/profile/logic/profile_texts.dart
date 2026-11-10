import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/model/memory.dart';

/// "Explorator · 640 / 1000 XP", or "Legendă · 3100 XP" at the top.
String levelLine(LevelInfo info) {
  final next = info.nextAt;
  return next == null ? '${info.name} · ${info.xp} XP' : '${info.name} · ${info.xp} / $next XP';
}

/// "Următorul: Cartograf", or "Nivel maxim" at the top.
String nextLevelLine(LevelInfo info) {
  final next = info.nextName;
  return next == null ? 'Nivel maxim' : 'Următorul: $next';
}

/// The user document Profil follows: the signed-in account's id, else the id
/// stored on the user; null when neither is known (never an empty id, which
/// Firestore refuses).
String? profileDocId(String? accountUid, String userUid) {
  if (accountUid != null && accountUid.isNotEmpty) return accountUid;
  return userUid.isEmpty ? null : userUid;
}

/// "Sistem", "Luminos" or "Întunecat".
String themeLabel(ThemeMode mode) => switch (mode) {
      ThemeMode.system => 'Sistem',
      ThemeMode.light => 'Luminos',
      ThemeMode.dark => 'Întunecat',
    };

/// The first letters of the first two words, upper-case; "" for a blank name.
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  // By rune, not code unit: a name may start with an emoji.
  return words.take(2).map((w) => String.fromCharCode(w.runes.first).toUpperCase()).join();
}

/// The label under a stat, singular for 1: [kind] is `games`, `missions` or `podiums`.
String statLabel(String kind, int n) {
  final one = n == 1;
  return switch (kind) {
    'games' => one ? 'joc' : 'jocuri',
    'missions' => one ? 'misiune' : 'misiuni',
    'podiums' => one ? 'podium' : 'podiumuri',
    _ => kind,
  };
}

/// "Locul 2 · 1:48 · 6 poze"; what is not known is left out.
/// "1:48" for 108 minutes.
String memoryTime(int minutes) => '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';

String memoryLine(Memory memory, {int? photoCount}) {
  final place = memory.place;
  final minutes = memory.totalMinutes;
  final photos = photoCount ?? memory.photoUrls.length;
  return [
    if (place != null) 'Locul $place',
    if (minutes != null) memoryTime(minutes),
    if (photos > 0) photos == 1 ? '1 poză' : '$photos poze',
  ].join(' · ');
}
