import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/features/admin/home/logic/admin_hero.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';
import 'package:teamxperience/ui/components/layout/stat_tile.dart';

/// The numbers under the hero: live counts while an event runs, preparation
/// counts while one is about to start.
class AdminStatsPanel extends StatelessWidget {
  const AdminStatsPanel({super.key, required this.hero, required this.stats});

  final AdminHero hero;
  final AdminEventStats stats;

  @override
  Widget build(BuildContext context) {
    final current = hero;
    switch (current) {
      case AdminLiveHero():
        return _panel('În acest moment', [
          StatTile(
            label: 'Echipe',
            value: '${stats.teams}',
            icon: Icons.groups_outlined,
          ),
          StatTile(
            label: 'Persoane',
            value: '${stats.persons}',
            icon: Icons.person_outline,
          ),
          StatTile(
            label: 'Au terminat',
            value: '${stats.finished}',
            icon: Icons.flag_outlined,
          ),
        ]);
      case AdminSoonHero():
        return _panel('Pregătire', [
          StatTile(
            label: 'Echipe înscrise',
            value: '${stats.teams}',
            icon: Icons.groups_outlined,
          ),
          StatTile(
            label: 'Persoane',
            value: '${stats.persons}',
            icon: Icons.person_outline,
          ),
        ]);
      case NoAdminHero():
        return const SizedBox.shrink();
    }
  }

  Widget _panel(String title, List<Widget> tiles) {
    return SectionCard(
      title: title,
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }
}
