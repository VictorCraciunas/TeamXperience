import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/features/admin/home/controller/admin_controller.dart';
import 'package:teamxperience/features/admin/home/logic/admin_hero.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_hero_actions.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_hero_section.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_quick_actions_panel.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_stats_panel.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_upcoming_panel.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late final AdminHomeController controller;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    controller = AdminHomeController(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInitialData();
    });
    // Keeps the live numbers fresh while an event runs.
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) controller.reloadStats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  AdminHeroActions get _actions => AdminHeroActions(
        onManage: controller.navigateToEventManagement,
        onMap: controller.navigateToMap,
        onChats: controller.navigateToChats,
        onTeams: controller.navigateToRegisteredTeams,
        onNotify: controller.navigateToNotificationFor,
      );

  Event? _heroEvent(AdminHero hero) {
    return switch (hero) {
      AdminLiveHero() => hero.event,
      AdminSoonHero() => hero.event,
      NoAdminHero() => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "TeamXperience"),
      body: SafeArea(
        child: Consumer<EventList>(
          builder: (context, eventList, child) {
            if (eventList.isLoading && !eventList.hasData) {
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
                  builder: (context, now) => AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => _content(now, eventList),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _content(DateTime now, EventList eventList) {
    final hero = resolveAdminHero(now: now, events: eventList.events);
    final heroEvent = _heroEvent(hero);
    final stats = controller.statsFor(heroEvent);
    final upcoming = eventList.upcomingEvents;

    return Column(
      children: [
        AdminHeroSection(hero: hero, now: now, stats: stats, actions: _actions),
        if (hero is! NoAdminHero) ...[
          const SizedBox(height: 14),
          AdminStatsPanel(hero: hero, stats: stats),
          const SizedBox(height: 14),
        ],
        AdminQuickActionsPanel(
          onCreateEvent: controller.navigateToCreateEvent,
          onCreateNews: controller.navigateToCreateNews,
          onNotify: controller.navigateToNotification,
        ),
        const SizedBox(height: 14),
        AdminUpcomingPanel(
          events: upcoming,
          statsFor: controller.statsFor,
          onTap: controller.navigateToEventDetails,
          onSeeAll: controller.navigateToEventsTab,
        ),
      ],
    );
  }
}
