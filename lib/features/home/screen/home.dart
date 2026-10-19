import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/features/home/controller/home_controller.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/logic/preparation_steps.dart';
import 'package:teamxperience/features/home/widgets/events_panel.dart';
import 'package:teamxperience/features/home/widgets/home_hero_actions.dart';
import 'package:teamxperience/features/home/widgets/home_hero_section.dart';
import 'package:teamxperience/features/home/widgets/how_it_works_panel.dart';
import 'package:teamxperience/features/home/widgets/news_panel.dart';
import 'package:teamxperience/features/home/widgets/preparation_panel.dart';
import 'package:teamxperience/features/home/widgets/registrations_panel.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/news_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';
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
  int? _heroTeamCount;

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
    _heroTeamCount = null;

    if (hero is UpcomingHero) {
      controller.teamFor(event).then((team) {
        if (mounted && _extrasFor == event.eventId) setState(() => _heroTeam = team);
      });
    } else if (hero is RecommendedHero) {
      controller.teamCountFor(event).then((count) {
        if (mounted && _extrasFor == event.eventId) setState(() => _heroTeamCount = count);
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
                  MyPaddings.appHorizontalPadding,
                  MyPaddings.topPaddingHome,
                  MyPaddings.appHorizontalPadding,
                  24,
                ),
                child: ClockBuilder(
                  builder: (context, now) => _content(now, eventList, newsList, userEvents),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _content(
    DateTime now,
    EventList eventList,
    NewsList newsList,
    UserEventsProvider userEvents,
  ) {
    final registered = userEvents.registeredEvents;
    final upcomingRegistered = userEvents.upcomingRegisteredEvents;
    final hero = resolveHomeHero(
      now: now,
      activeEvent: userEvents.activeEvent,
      activeTeam: userEvents.activeTeam,
      startedRecently: userEvents.recentlyStartedEvent,
      startedRecentlyTeam: null,
      registeredUpcoming: upcomingRegistered,
      allEvents: eventList.events,
      registeredIds: registered.map((e) => e.eventId).toSet(),
    );
    _loadExtras(hero);

    final heroEvent = _heroEvent(hero);
    final events = eventList.upcomingEvents;
    final registrations = upcomingRegistered
        .where((e) => e.eventId != heroEvent?.eventId || hero is! UpcomingHero)
        .toList();

    return Column(
      children: [
        HomeHeroSection(
          hero: hero,
          now: now,
          actions: _actions(),
          recommendedTeamCount: _heroTeamCount,
        ),
        if (hero is! NoHero) const SizedBox(height: 14),
        if (hero is UpcomingHero && heroEvent != null) ...[
          PreparationPanel(steps: preparationSteps(heroEvent, _heroTeam, now)),
          const SizedBox(height: 14),
        ],
        if (hero is RecommendedHero || hero is NoHero) ...[
          const HowItWorksPanel(),
          const SizedBox(height: 14),
        ],
        if (registrations.isNotEmpty) ...[
          RegistrationsPanel(
            events: registrations,
            onTap: controller.navigateToTeamDetails,
            onSeeAll: controller.navigateToEventDashboard,
          ),
          const SizedBox(height: 14),
        ],
        EventsPanel(
          events: events,
          onTap: controller.navigateToEventDetails,
          onSeeAll: controller.navigateToEventDashboard,
        ),
        const SizedBox(height: 14),
        NewsPanel(
          news: newsList.getLatestNews(5),
          onTap: controller.navigateToStireDetails,
          onSeeAll: controller.navigateToNewsTab,
        ),
      ],
    );
  }
}
