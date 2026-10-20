import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_hero_card.dart';
import 'package:teamxperience/ui/components/event/format_remaining.dart';
import 'package:teamxperience/ui/components/event/hero_action.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

/// Maps a [HomeHero] to the shared [EventHeroCard] with the player's wording.
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    required this.hero,
    required this.now,
    required this.actions,
    this.recommendedTeamCount,
  });

  final HomeHero hero;
  final DateTime now;
  final HomeHeroActions actions;
  final int? recommendedTeamCount;

  @override
  Widget build(BuildContext context) {
    final current = hero;
    switch (current) {
      case LiveHero():
        return _live(current);
      case StartingSoonHero():
        return _startingSoon(current);
      case UpcomingHero():
        return _upcoming(current);
      case RecommendedHero():
        return _recommended(current);
      case NoHero():
        return const SizedBox.shrink();
    }
  }

  String? _image(Event event) {
    final url = event.landingImageUrl;
    return (url == null || url.isEmpty) ? null : url;
  }

  Widget _live(LiveHero hero) {
    final event = hero.event;
    final team = hero.team;
    final start = event.dateEvent;
    final remaining =
        start == null
            ? Duration.zero
            : start.add(Event.maxDuration).difference(now);
    final total = event.nrMissions;
    final mission = total <= 0 ? 1 : (team.missionProgress + 1).clamp(1, total);

    return EventHeroCard(
      status: HeroStatus.live,
      statusLabel: 'LIVE',
      title: event.name ?? '',
      subtitle:
          total <= 0
              ? team.name
              : '${team.name} · Misiunea $mission din $total',
      timeChip: '${formatRemaining(remaining)} rămase',
      imageUrl: _image(event),
      progressDone: total > 0 ? team.missionProgress : null,
      progressTotal: total > 0 ? total : null,
      primary: HeroAction(
        label: 'Continuă jocul',
        icon: Icons.play_arrow_rounded,
        onTap: () => actions.onContinue(event, team),
      ),
      secondaryIcon: Icons.chat_bubble_outline,
      secondaryLabel: 'Chat cu organizatorii',
      onSecondary: () => actions.onChat(event, team),
    );
  }

  Widget _startingSoon(StartingSoonHero hero) {
    final event = hero.event;
    return EventHeroCard(
      status: HeroStatus.soon,
      statusLabel: 'A început',
      title: event.name ?? '',
      subtitle: 'Cere codul de start de la organizatori.',
      timeChip: 'Mai ai ${hero.minutesLeftToEnter} min să intri',
      imageUrl: _image(event),
      primary: HeroAction(
        label: 'Introdu codul de start',
        icon: Icons.key_outlined,
        onTap: () => actions.onEnterCode(event),
      ),
    );
  }

  Widget _upcoming(UpcomingHero hero) {
    final event = hero.event;
    final location = event.location;
    final parts = [
      if (location != null && location.isNotEmpty) location,
      CalendarHelper.formatEventDate(event.dateEvent),
      CalendarHelper.formatEventTime(event.dateEvent),
    ];

    return EventHeroCard(
      status: HeroStatus.upcoming,
      statusLabel: 'Următorul eveniment',
      title: event.name ?? '',
      subtitle: parts.join(' · '),
      countdown: hero.untilStart,
      imageUrl: _image(event),
      primary: HeroAction(
        label: 'Detalii înscriere',
        onTap: () => actions.onDetails(event),
      ),
      secondaryIcon: Icons.share_outlined,
      secondaryLabel: 'Distribuie înscrierea',
      onSecondary: () => actions.onShare(event),
    );
  }

  Widget _recommended(RecommendedHero hero) {
    final event = hero.event;
    final route = event.lungimeTraseu;
    final count = recommendedTeamCount;
    final facts = [
      CalendarHelper.formatEventDate(event.dateEvent),
      if (route != null && route.isNotEmpty) route,
      if (count != null) '$count echipe',
    ];

    return EventHeroCard(
      status: HeroStatus.recommended,
      statusLabel: 'Recomandat pentru tine',
      title: event.name ?? '',
      subtitle: facts.join(' · '),
      imageUrl: _image(event),
      primary: HeroAction(
        label: 'Înscrie-ți echipa',
        icon: Icons.group_add_outlined,
        onTap: () => actions.onRegister(event),
      ),
    );
  }
}
