import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/widgets/greeting_stats.dart';
import 'package:teamxperience/features/home/widgets/home_header.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/features/home/widgets/home_hero_section.dart';
import 'package:teamxperience/features/home/widgets/live_leaderboard_section.dart';
import 'package:teamxperience/features/home/widgets/events_grid_section.dart';
import 'package:teamxperience/features/home/widgets/team_now_card.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/service/leaderboard.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/components/navigation/app_bottom_nav.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// The Acasă tab of mockup 02 with its data, before and during a game,
/// inside the five-tab bar.
class HomePreview extends StatefulWidget {
  const HomePreview({super.key});

  @override
  State<HomePreview> createState() => _HomePreviewState();
}

class _HomePreviewState extends State<HomePreview> {
  /// 3 days 14 h 22 min before the sample event.
  static final _before = DateTime(2026, 11, 10, 19, 38);

  /// 1:17:42 before the sample event's end.
  static final _live = DateTime(2026, 11, 14, 11, 42, 18);

  int _state = 0;

  void _say(String what) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(what)));

  HomeHeroActions get _actions => HomeHeroActions(
        onContinue: (_, _) => _say('continue'),
        onChat: (_, _) => _say('chat'),
        onEnterCode: (_) => _say('code'),
        onDetails: (_) => _say('details'),
        onShare: (_) => _say('share'),
        onRegister: (_) => _say('register'),
      );

  List<Widget> _beforeGame() {
    final event = sampleEvent();
    final start = event.dateEvent ?? _before;
    return [
      const GreetingStats(firstName: 'Victor', games: 3, distanceMeters: 12400, xp: 800),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: HomeHeroSection(
          hero: UpcomingHero(event, start.difference(_before)),
          now: _before,
          actions: _actions,
          upcomingTeam: sampleTeam(),
        ),
      ),
      EventsGridSection(
        title: 'Evenimente noi',
        link: 'Vezi toate',
        onLink: () => _say('all'),
        events: sampleOpenEvents(),
        onTap: (e) => _say('open ${e.name}'),
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _duringGame() {
    final event = sampleEvent();
    final teams = sampleLiveTeams(_live);
    final ours = teams.firstWhere((t) => t.name == 'Vulpile');
    return [
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: HomeHeroSection(hero: LiveHero(event, ours), now: _live, actions: _actions),
      ),
      LiveLeaderboardSection(
        ranked: rankTeams(teams, missionCount: event.nrMissions),
        ownName: ours.name,
        missionCount: event.nrMissions,
        onAll: () => _say('all'),
      ),
      TeamNowCard(team: ours, now: _live),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final live = _state == 1;
    return Scaffold(
      backgroundColor: context.colors.page,
      body: Column(
        children: [
          HomeHeader(unread: !live, onBell: () => _say('știri')),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 0),
            child: SegmentedSwitch(
              labels: const ['Înainte de joc', 'În timpul jocului'],
              selectedIndex: _state,
              onSelected: (i) => setState(() => _state = i),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: live ? _duringGame() : _beforeGame(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: PlayerTab.home,
        onSelected: (i) => _say('tab $i'),
        items: playerNavItems(live: live),
      ),
    );
  }
}
