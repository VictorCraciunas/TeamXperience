import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/events_tab/logic/event_sections.dart';
import 'package:teamxperience/features/home/controller/home_controller.dart';
import 'package:teamxperience/features/home/controller/home_live_controller.dart';
import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/features/home/controller/home_extras_controller.dart';
import 'package:teamxperience/features/home/logic/hero_from_providers.dart';
import 'package:teamxperience/features/home/logic/home_content.dart';
import 'package:teamxperience/features/home/widgets/home_layout.dart';
import 'package:teamxperience/features/home/widgets/home_memory_card.dart';
import 'package:teamxperience/features/home/widgets/home_news_carousel.dart';
import 'package:teamxperience/features/home/widgets/home_season_card.dart';
import 'package:teamxperience/features/home/widgets/how_it_works_sheet.dart';
import 'package:teamxperience/features/home/widgets/new_player_greeting.dart';
import 'package:teamxperience/features/home/widgets/nothing_open_banner.dart';
import 'package:teamxperience/features/profile/logic/profile_texts.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/logic/live_watch.dart';
import 'package:teamxperience/features/home/logic/news_seen.dart';
import 'package:teamxperience/features/home/widgets/events_grid_section.dart';
import 'package:teamxperience/features/home/widgets/greeting_stats.dart';
import 'package:teamxperience/features/home/widgets/home_header.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/features/home/widgets/home_hero_ticker.dart';
import 'package:teamxperience/features/home/widgets/leaderboard_sheet.dart';
import 'package:teamxperience/features/home/widgets/live_leaderboard_section.dart';

import 'package:teamxperience/features/home/widgets/team_now_card.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/news_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';
import 'package:teamxperience/ui/ui.dart';

/// The player's Acasă tab: pictures lead, and there is always something to see
/// (see [HomeLayout]). During a game the live card, the live leaderboard and
/// who of the team is playing.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final HomeController controller;
  late final HomeLiveController _live;
  late final HomeExtrasController _extras;
  final NewsSeenStore _newsSeen = NewsSeenStore();
  DateTime? _lastSeenNews;

  /// The team of the next game, loaded once per hero event.
  String? _extrasFor;
  Team? _heroTeam;

  @override
  void initState() {
    super.initState();
    controller = HomeController(context);
    _live = HomeLiveController(teams: controller.teamService.getStreamTeams)..addListener(_onLiveTeams);
    _extras = HomeExtrasController(
      memories: (uid) => UserRepo().streamMemories(uid, limit: 1),
      crews: controller.teamService.streamUserCrews,
      standings: controller.teamService.streamStandings(seasonOf(DateTime.now()).id),
      seasonName: seasonOf(DateTime.now()).name,
      findTeam: controller.teamService.getUserTeamForEvent,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInitialData();
      context.read<UserEventsProvider>().loadActiveEvent();
    });
    _newsSeen.lastSeen().then((at) {
      if (mounted) setState(() => _lastSeenNews = at);
    });
  }

  @override
  void dispose() {
    _live
      ..removeListener(_onLiveTeams)
      ..dispose();
    _extras.dispose();
    super.dispose();
  }

  void _loadExtras(HomeHero hero) {
    final event = hero is UpcomingHero ? hero.event : null;
    if (event == null || _extrasFor == event.eventId) return;
    _extrasFor = event.eventId;
    _heroTeam = null;
    controller.teamFor(event).then((team) {
      if (mounted && _extrasFor == event.eventId) setState(() => _heroTeam = team);
    });
  }

  /// Follows the live game's teams while Home is on screen; after the frame,
  /// so the controller never notifies while this page is building.
  void _watchLive(HomeHero hero, {required bool visible}) {
    final event = liveEventToWatch(hero, visible: visible);
    _liveTeamName = hero is LiveHero ? hero.team.name : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _live.watch(event);
    });
  }

  /// The live team's name, and whether its finish was already reported.
  String? _liveTeamName;
  bool _finishReported = false;

  /// When the stream says the team has finished, refresh the active game so
  /// Home leaves the live layout at once.
  void _onLiveTeams() {
    final name = _liveTeamName;
    if (name == null) return;
    final finished = _live.own(name)?.hasFinished ?? false;
    if (finished && !_finishReported) {
      _finishReported = true;
      context.read<UserEventsProvider>().loadActiveEvent();
    } else if (!finished) {
      _finishReported = false;
    }
  }

  Future<void> _openNews() async {
    final now = DateTime.now();
    setState(() => _lastSeenNews = now);
    await controller.openNews(_newsSeen, now);
  }

  HomeHeroActions _actions() {
    return HomeHeroActions(
      onContinue: controller.openGame,
      onChat: controller.openChat,
      onEnterCode: controller.navigateToEnterCodeScreen,
      onDetails: controller.navigateToTeamDetails,
      onShare: (event) => controller.shareRegistration(event),
      onRegister: controller.navigateToRegisterTeam,
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserProvider>();
    final user = users.currentUser;
    // After the frame, so the controller never notifies while this page builds.
    final uid = profileDocId(users.firebaseUser?.uid, user?.uid ?? '');
    final onScreen =
        context.watch<ShellController>().index == PlayerTab.home && (ModalRoute.of(context)?.isCurrent ?? true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _extras
        ..watch(uid)
        ..setVisible(onScreen);
    });
    final games = user?.stats.games ?? 0;
    final xp = user?.xp ?? 0;
    // On screen: Acasă is the current tab and no page is pushed over the shell.
    final visible =
        context.watch<ShellController>().index == PlayerTab.home && (ModalRoute.of(context)?.isCurrent ?? true);
    return Scaffold(
      backgroundColor: context.colors.page,
      body: Consumer3<EventList, NewsList, UserEventsProvider>(
        builder: (context, eventList, newsList, userEvents, child) {
          final loading =
              (eventList.isLoading && !eventList.hasData) || (newsList.isLoading && !newsList.hasData);
          return Column(
            children: [
              HomeHeader(unread: hasUnreadNews(newsList.stireList, _lastSeenNews), onBell: _openNews),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : eventList.loadFailed
                    ? LoadFailed(message: 'Nu am putut încărca evenimentele.', onRetry: controller.refreshData)
                    : RefreshIndicator(
                        onRefresh: () async {
                          await controller.refreshData();
                          await _extras.reloadAlbum();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ListenableBuilder(
                            listenable: _extras,
                            builder: (context, _) => _content(
                              eventList,
                              newsList,
                              userEvents,
                              visible,
                              isNewPlayer(games, xp)
                                  ? NewPlayerGreeting(
                                      firstName: user?.firstName ?? '',
                                      onHow: () => showHowItWorksSheet(context),
                                    )
                                  : GreetingStats(
                                      firstName: user?.firstName ?? '',
                                      games: games,
                                      distanceMeters: user?.stats.distanceMeters ?? 0,
                                      xp: xp,
                                    ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The event's main picture, when the event is loaded.
  String? _pictureOf(EventList eventList, String eventId) {
    for (final event in eventList.events) {
      if (event.eventId == eventId) return event.landingImageUrl;
    }
    return null;
  }

  /// Built once per data change. Only the hero card ticks each second (see
  /// [HomeHeroTicker]); the live sections refresh every 30 s for "acum 6 min".
  Widget _content(EventList eventList, NewsList newsList, UserEventsProvider userEvents, bool visible, Widget greeting) {
    final now = DateTime.now();
    HomeHero resolve(DateTime at) => heroFromProviders(userEvents: userEvents, eventList: eventList, now: at);
    final hero = resolve(now);
    _loadExtras(hero);
    _watchLive(hero, visible: visible);

    final registeredIds = {for (final e in userEvents.registeredEvents) e.eventId};
    final open = sectionEvents(eventList.events, registeredIds, now).open;
    final newEvents = newEventsToShow(open, hero);
    final pastGames = hero is NoHero ? pastGamesToShow(eventList.pastEvents, now) : const <Event>[];
    final newest = _extras.memory;
    final first = memoryGoesFirst(newest, now);
    final spot = _extras.seasonSpot;
    final latest = latestNews(newsList.stireList, now);

    Widget memoryCard(Memory memory, {required bool large}) => HomeMemoryCard(
          memory: memory,
          album: _extras.album,
          eventPicture: _pictureOf(eventList, memory.eventId),
          large: large,
          onOpen: () => controller.openMemory(memory),
          onAll: controller.openAllMemories,
        );

    return HomeLayout(
      hero: hero,
      greeting: greeting,
      memoryFirst: newest != null && first ? memoryCard(newest, large: true) : null,
      mainCard: hero is NoHero
          ? (showNothingOpen(hero, newEvents) ? const NothingOpenBanner() : null)
          : HomeHeroTicker(
              resolve: resolve,
              shown: hero,
              actions: _actions(),
              upcomingTeam: _heroTeam,
              liveTeam: _live.own,
              onLayoutChange: () {
                if (mounted) setState(() {});
              },
            ),
      live: hero is LiveHero ? _liveSections(hero.event, hero.team) : null,
      newEvents: newEvents.isEmpty
          ? null
          : EventsGridSection(
              title: 'Evenimente noi',
              link: 'Vezi toate',
              onLink: controller.navigateToEventDashboard,
              events: newEvents,
              onTap: controller.navigateToEventDetails,
            ),
      memory: newest != null && !first ? memoryCard(newest, large: false) : null,
      pastGames: pastGames.isEmpty
          ? null
          : EventsGridSection(title: 'Jocuri trecute', events: pastGames, onTap: controller.navigateToEventDetails),
      season: spot == null
          ? null
          : HomeSeasonCard(
              seasonName: _extras.seasonName,
              place: spot.place,
              standing: spot.standing,
              onOpen: controller.openTeamsTab,
            ),
      news: latest.isEmpty
          ? null
          : HomeNewsCarousel(
              items: latest,
              onOpen: controller.navigateToStireDetails,
              onAll: controller.navigateToNewsTab,
            ),
    );
  }

  Widget _liveSections(Event event, Team heroTeam) {
    return ListenableBuilder(
      listenable: _live,
      builder: (context, _) => ClockBuilder(
        interval: const Duration(seconds: 30),
        builder: (context, now) {
          final ranked = _live.ranked;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              LiveLeaderboardSection(
                ranked: ranked,
                ownName: heroTeam.name,
                missionCount: event.nrMissions,
                onAll: () => showLeaderboardSheet(
                  context,
                  ranked: ranked,
                  ownName: heroTeam.name,
                  missionCount: event.nrMissions,
                ),
              ),
              TeamNowCard(team: _live.own(heroTeam.name) ?? heroTeam, now: now),
            ],
          );
        },
      ),
    );
  }
}
