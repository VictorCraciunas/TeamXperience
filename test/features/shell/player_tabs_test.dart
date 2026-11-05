import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';

void main() {
  test('five tabs in the mockup order, Joacă raised in the middle', () {
    final items = playerNavItems(live: false);
    expect(items.map((i) => i.label), ['Acasă', 'Evenimente', 'Joacă', 'Echipe', 'Profil']);
    expect(items.map((i) => i.icon), [
      TablerIcons.home,
      TablerIcons.map_2,
      TablerIcons.key,
      TablerIcons.users_group,
      TablerIcons.user,
    ]);
    expect([for (final i in items) i.raised], [false, false, true, false, false]);
    expect(items[PlayerTab.play].live, isFalse);
  });

  test('during a game the middle tab reads "În joc" with a play icon and turns red', () {
    final play = playerNavItems(live: true)[PlayerTab.play];
    expect((play.label, play.icon, play.raised, play.live), ('În joc', TablerIcons.player_play, true, true));
  });

  test('tab numbers have names, matching the order', () {
    final labels = playerNavItems(live: false).map((i) => i.label).toList();
    expect(labels[PlayerTab.home], 'Acasă');
    expect(labels[PlayerTab.events], 'Evenimente');
    expect(labels[PlayerTab.play], 'Joacă');
    expect(labels[PlayerTab.teams], 'Echipe');
    expect(labels[PlayerTab.profile], 'Profil');
  });
}
