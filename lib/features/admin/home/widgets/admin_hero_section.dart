import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/features/admin/home/logic/admin_hero.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_hero_actions.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_hero_card.dart';
import 'package:teamxperience/ui/components/event/format_remaining.dart';
import 'package:teamxperience/ui/components/event/hero_action.dart';

/// Maps an [AdminHero] to the shared [EventHeroCard] with the organiser wording.
class AdminHeroSection extends StatelessWidget {
  const AdminHeroSection({
    super.key,
    required this.hero,
    required this.now,
    required this.stats,
    required this.actions,
  });

  final AdminHero hero;
  final DateTime now;
  final AdminEventStats stats;
  final AdminHeroActions actions;

  @override
  Widget build(BuildContext context) {
    final current = hero;
    switch (current) {
      case AdminLiveHero():
        return _live(current.event);
      case AdminSoonHero():
        return _soon(current);
      case NoAdminHero():
        return const SizedBox.shrink();
    }
  }

  String? _image(Event event) {
    final url = event.landingImageUrl;
    return (url == null || url.isEmpty) ? null : url;
  }

  Widget _live(Event event) {
    final start = event.dateEvent;
    final remaining =
        start == null
            ? Duration.zero
            : start.add(Event.maxDuration).difference(now);

    return EventHeroCard(
      status: HeroStatus.live,
      statusLabel: 'LIVE',
      title: event.name ?? '',
      subtitle:
          '${stats.teams} echipe · ${stats.finished} au terminat · ${stats.inPlay} în joc',
      timeChip: '${formatRemaining(remaining)} rămase',
      imageUrl: _image(event),
      primary: HeroAction(
        label: 'Gestionează eveniment',
        icon: Icons.tune,
        onTap: () => actions.onManage(event),
      ),
      secondaryIcon: Icons.map_outlined,
      secondaryLabel: 'Harta echipelor',
      onSecondary: () => actions.onMap(event),
      moreActions: [
        HeroIconAction(
          icon: Icons.chat_bubble_outline,
          label: 'Conversații cu echipele',
          onTap: () => actions.onChats(event),
        ),
      ],
    );
  }

  Widget _soon(AdminSoonHero hero) {
    final event = hero.event;
    final minutes = hero.untilStart.inMinutes;

    return EventHeroCard(
      status: HeroStatus.soon,
      statusLabel: 'Urmează',
      title: event.name ?? '',
      subtitle: '${stats.teams} echipe înscrise · ${stats.persons} persoane',
      timeChip: 'Începe în ${minutes ~/ 60} h ${minutes % 60} min',
      imageUrl: _image(event),
      primary: HeroAction(
        label: 'Vezi echipele înscrise',
        icon: Icons.groups_outlined,
        onTap: () => actions.onTeams(event),
      ),
      secondaryIcon: Icons.notifications_none,
      secondaryLabel: 'Trimite notificare',
      onSecondary: () => actions.onNotify(event),
    );
  }
}
