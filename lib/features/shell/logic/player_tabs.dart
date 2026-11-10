import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/navigation/app_nav_item.dart';

/// The player shell's tab numbers, so nothing switches tabs by a bare index.
abstract class PlayerTab {
  static const home = 0;
  static const events = 1;
  static const play = 2;
  static const teams = 3;
  static const profile = 4;
}

/// The bottom bar of mockups 02, 03 and 08. While a game is on, the middle
/// tab reads "În joc" with a play icon and turns red.
/// [open] marks the middle tab while the Joacă pop-up is shown.
List<AppNavItem> playerNavItems({required bool live, bool open = false}) => [
      const AppNavItem(icon: TablerIcons.home, label: 'Acasă'),
      const AppNavItem(icon: TablerIcons.map_2, label: 'Evenimente'),
      AppNavItem(
        icon: live ? TablerIcons.player_play : TablerIcons.key,
        label: live ? 'În joc' : 'Joacă',
        raised: true,
        live: live,
        open: open,
      ),
      const AppNavItem(icon: TablerIcons.users_group, label: 'Echipe'),
      const AppNavItem(icon: TablerIcons.user, label: 'Profil'),
    ];
