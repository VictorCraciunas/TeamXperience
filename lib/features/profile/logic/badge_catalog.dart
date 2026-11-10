import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// One badge a player can earn. The end-of-event function (7c) writes the
/// earned ids to `users/{uid}.badges`; the catalogue itself lives here.
class ProfileBadge {
  const ProfileBadge({required this.id, required this.title, required this.icon, required this.rule, this.gold = false});

  /// Stable: stored on the user document.
  final String id;
  final String title;
  final IconData icon;

  /// How to earn it, shown on a locked badge.
  final String rule;

  /// Drawn in the warm colours instead of the teal ones.
  final bool gold;
}

/// The twelve badges, in the order they are listed.
const List<ProfileBadge> badgeCatalog = [
  ProfileBadge(id: 'km10', title: 'Primii 10 km', icon: TablerIcons.shoe, rule: 'Parcurge 10 km în total'),
  ProfileBadge(id: 'noHints', title: 'Fără indicii', icon: TablerIcons.bolt, rule: 'Termină un joc fără niciun indiciu', gold: true),
  ProfileBadge(id: 'night', title: 'Joc nocturn', icon: TablerIcons.moon, rule: 'Joacă un joc care se termină după lăsarea serii'),
  ProfileBadge(id: 'winner', title: 'Câștigă un joc', icon: TablerIcons.trophy, rule: 'Termină un joc pe locul 1', gold: true),
  ProfileBadge(id: 'firstGame', title: 'Primul joc', icon: TablerIcons.flag, rule: 'Termină primul tău joc'),
  ProfileBadge(id: 'games5', title: '5 jocuri', icon: TablerIcons.run, rule: 'Termină 5 jocuri'),
  ProfileBadge(id: 'km50', title: '50 km', icon: TablerIcons.route, rule: 'Parcurge 50 km în total'),
  ProfileBadge(id: 'podium3', title: '3 podiumuri', icon: TablerIcons.medal, rule: 'Urcă pe podium de 3 ori', gold: true),
  ProfileBadge(id: 'photo', title: 'Poză aprobată', icon: TablerIcons.camera, rule: 'Primește o poză aprobată cu insignă'),
  ProfileBadge(id: 'fast', title: 'Misiune sub 5 min', icon: TablerIcons.clock, rule: 'Rezolvă o misiune în mai puțin de 5 minute'),
  ProfileBadge(id: 'missions50', title: '50 de misiuni', icon: TablerIcons.map_2, rule: 'Rezolvă 50 de misiuni în total'),
  ProfileBadge(id: 'crew', title: 'Echipa completă', icon: TablerIcons.users_group, rule: 'Joacă un joc cu echipa completă'),
];

/// How many of the catalogue's badges are in [earnedIds] (unknown ids do not count).
int earnedCount(List<String> earnedIds) =>
    badgeCatalog.where((badge) => earnedIds.contains(badge.id)).length;

/// The four badges the Profil row shows: the earned ones first, then locked
/// ones, each group in catalogue order.
List<ProfileBadge> badgesRow(List<String> earnedIds) {
  final earned = badgeCatalog.where((badge) => earnedIds.contains(badge.id));
  final locked = badgeCatalog.where((badge) => !earnedIds.contains(badge.id));
  return [...earned, ...locked].take(4).toList();
}
