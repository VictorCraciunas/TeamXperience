import 'package:flutter/widgets.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/features/home/widgets/home_hero_section.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';

/// The Home hero card, redrawn every second for its countdown. Only this card
/// ticks: the panels below it are rebuilt just when the kind of hero changes
/// (for example upcoming -> starting soon), which is reported through
/// [onLayoutChange], so the page is not rebuilt every second.
class HomeHeroTicker extends StatelessWidget {
  const HomeHeroTicker({
    super.key,
    required this.resolve,
    required this.shown,
    required this.actions,
    required this.onLayoutChange,
    this.upcomingTeam,
    this.liveTeam,
    this.now,
  });

  /// The hero for a given time.
  final HomeHero Function(DateTime now) resolve;

  /// The hero the rest of the page was laid out for.
  final HomeHero shown;
  final HomeHeroActions actions;
  final VoidCallback onLayoutChange;
  final Team? upcomingTeam;
  final Team? Function(String teamName)? liveTeam;

  /// Overrides the clock (for tests).
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    return ClockBuilder(
      now: now,
      builder: (context, time) {
        final hero = resolve(time);

        if (hero.signature != shown.signature) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onLayoutChange());
        }

        return HomeHeroSection(
          hero: hero,
          now: time,
          actions: actions,
          upcomingTeam: upcomingTeam,
          liveTeam: liveTeam,
        );
      },
    );
  }
}
