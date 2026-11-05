import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/model/team.dart';

import 'live_game_card.dart';
import 'next_game_card.dart';
import 'recommended_card.dart';
import 'starting_soon_card.dart';

/// The card at the top of Home for the current [HomeHero] (mockup 02).
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    required this.hero,
    required this.now,
    required this.actions,
    this.upcomingTeam,
  });

  final HomeHero hero;
  final DateTime now;
  final HomeHeroActions actions;

  /// The player's team for the next game, once loaded: its preparation shows
  /// on the next-game card.
  final Team? upcomingTeam;

  @override
  Widget build(BuildContext context) {
    final current = hero;
    return switch (current) {
      LiveHero(:final event, :final team) => LiveGameCard(
          event: event,
          team: team,
          now: now,
          onContinue: () => actions.onContinue(event, team),
          onChat: () => actions.onChat(event, team),
        ),
      StartingSoonHero(:final event, :final minutesLeftToEnter) => StartingSoonCard(
          event: event,
          minutesLeft: minutesLeftToEnter,
          onEnterCode: () => actions.onEnterCode(event),
        ),
      UpcomingHero(:final event, :final untilStart) => NextGameCard(
          event: event,
          left: untilStart,
          now: now,
          team: upcomingTeam,
          onTap: () => actions.onDetails(event),
        ),
      RecommendedHero(:final event) => RecommendedCard(
          event: event,
          onRegister: () => actions.onRegister(event),
        ),
      NoHero() => const SizedBox.shrink(),
    };
  }
}
