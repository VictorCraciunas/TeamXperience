import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/home/controller/home_controller.dart';
import 'package:teamxperience/features/home/logic/hero_from_providers.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/widgets/events_panel.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/features/home/widgets/home_hero_ticker.dart';
import 'package:teamxperience/features/home/widgets/how_it_works_panel.dart';
import 'package:teamxperience/features/home/widgets/news_panel.dart';
import 'package:teamxperience/features/home/widgets/registrations_panel.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/news_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/components/misc/fade_in_section.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final HomeController controller;

  /// Extra data the hero needs, loaded once per hero event.
  String? _extrasFor;
  Team? _heroTeam;

  @override
  void initState() {
    super.initState();
    controller = HomeController(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInitialData();
      context.read<UserEventsProvider>().loadActiveEvent();
    });
  }

  Event? _heroEvent(HomeHero hero) {
    return switch (hero) {
      LiveHero() => hero.event,
      StartingSoonHero() => hero.event,
      UpcomingHero() => hero.event,
      RecommendedHero() => hero.event,
      NoHero() => null,
    };
  }

  void _loadExtras(HomeHero hero) {
    final event = _heroEvent(hero);
    if (event == null || _extrasFor == event.eventId) return;
    _extrasFor = event.eventId;
    _heroTeam = null;

    if (hero is UpcomingHero) {
      controller.teamFor(event).then((team) {
        if (mounted && _extrasFor == event.eventId) {
          setState(() => _heroTeam = team);
        }
      });
    }
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
    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "TeamXperience"),
      body: SafeArea(
        child: Consumer3<EventList, NewsList, UserEventsProvider>(
          builder: (context, eventList, newsList, userEvents, child) {
            if ((eventList.isLoading && !eventList.hasData) ||
                (newsList.isLoading && !newsList.hasData)) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.lg,
                  AppSpacing.page,
                  24,
                ),
                child: _content(eventList, newsList, userEvents),
              ),
            );
          },
        ),
      ),
    );
  }

  /// The page is built once per data change. Only the hero card ticks each
  /// second (see [HomeHeroTicker]); the panels are rebuilt when the kind of
  /// hero changes, not every second.
  Widget _content(
    EventList eventList,
    NewsList newsList,
    UserEventsProvider userEvents,
  ) {
    final now = DateTime.now();
    final upcomingRegistered = userEvents.upcomingRegisteredEvents;
    HomeHero resolve(DateTime at) =>
        heroFromProviders(userEvents: userEvents, eventList: eventList, now: at);
    final hero = resolve(now);
    _loadExtras(hero);

    final heroEvent = _heroEvent(hero);
    final events = eventList.upcomingEvents;
    final registrations =
        upcomingRegistered
            .where(
              (e) => e.eventId != heroEvent?.eventId || hero is! UpcomingHero,
            )
            .toList();

    // Sections fade in one after the other from the top, once. The keys keep
    // each section's animation state while the clock rebuilds this every second.
    var order = 0;
    Widget section(String key, Widget child) =>
        FadeInSection(key: ValueKey(key), order: order++, child: child);

    return Column(
      children: [
        section(
          'hero',
          HomeHeroTicker(
            resolve: resolve,
            shown: hero,
            actions: _actions(),
            upcomingTeam: _heroTeam,
            onLayoutChange: () {
              if (mounted) setState(() {});
            },
          ),
        ),
        if (hero is! NoHero) const SizedBox(height: 14),
        if (hero is RecommendedHero || hero is NoHero) ...[
          section('how-it-works', const HowItWorksPanel()),
          const SizedBox(height: 14),
        ],
        if (registrations.isNotEmpty) ...[
          section(
            'registrations',
            RegistrationsPanel(
              events: registrations,
              onTap: controller.navigateToTeamDetails,
              onSeeAll: controller.navigateToEventDashboard,
            ),
          ),
          const SizedBox(height: 14),
        ],
        section(
          'events',
          EventsPanel(
            events: events,
            onTap: controller.navigateToEventDetails,
            onSeeAll: controller.navigateToEventDashboard,
          ),
        ),
        const SizedBox(height: 14),
        section(
          'news',
          NewsPanel(
            news: newsList.getLatestNews(5),
            onTap: controller.navigateToStireDetails,
            onSeeAll: controller.navigateToNewsTab,
          ),
        ),
      ],
    );
  }
}
