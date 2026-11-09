import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/ui/components/misc/fade_in_section.dart';

/// The order of Acasă. A part that is null takes no space. During a game only
/// the card and the live parts follow the header.
class HomeLayout extends StatelessWidget {
  const HomeLayout({
    super.key,
    required this.hero,
    required this.greeting,
    this.memoryFirst,
    this.mainCard,
    this.live,
    this.newEvents,
    this.memory,
    this.pastGames,
    this.season,
    this.news,
  });

  final HomeHero hero;
  final Widget greeting;

  /// A game just played, above everything else.
  final Widget? memoryFirst;
  final Widget? mainCard;

  /// The leaderboard and the team, during a game.
  final Widget? live;
  final Widget? newEvents;
  final Widget? memory;
  final Widget? pastGames;
  final Widget? season;
  final Widget? news;

  @override
  Widget build(BuildContext context) {
    // Sections fade in one after the other from the top, once. The keys keep
    // each section's animation state while the page is rebuilt.
    var order = 0;
    Widget section(String key, Widget child) => FadeInSection(key: ValueKey(key), order: order++, child: child);

    final playing = hero is LiveHero;
    final card = mainCard;
    final liveParts = live;
    final first = memoryFirst;
    final events = newEvents;
    final later = memory;
    final past = pastGames;
    final crew = season;
    final latest = news;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!playing) section('greeting', greeting),
        if (!playing && first != null) section('memory-first', first),
        if (card != null)
          section(
            'hero',
            Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 0), child: card),
          ),
        if (playing) ...[
          if (liveParts != null) section('live', liveParts),
        ] else ...[
          if (events != null) section('events', events),
          if (later != null) section('memory', later),
          if (past != null) section('past', past),
          if (crew != null) section('season', crew),
          if (latest != null) section('news', latest),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
