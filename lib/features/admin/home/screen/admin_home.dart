import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/admin/home/controller/admin_controller.dart';
import 'package:teamxperience/features/admin/home/logic/admin_hero.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_drafts_panel.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_hero_actions.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_hero_section.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_quick_actions_panel.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_stats_panel.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_upcoming_panel.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';
import 'package:teamxperience/ui/components/misc/fade_in_section.dart';
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
            if (eventList.loadFailed) {
              return LoadFailed(message: 'Nu am putut încărca evenimentele.', onRetry: controller.refreshData);
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
                child: ClockBuilder(
                  builder:
                      (context, now) => AnimatedBuilder(
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

    // Sections fade in one after the other from the top, once.
    var order = 0;
    Widget section(String key, Widget child) =>
        FadeInSection(key: ValueKey(key), order: order++, child: child);

    return Column(
      children: [
        section(
          'hero',
          AdminHeroSection(hero: hero, now: now, stats: stats, actions: _actions),
        ),
        if (hero is! NoAdminHero) ...[
          const SizedBox(height: 14),
          section('stats', AdminStatsPanel(hero: hero, stats: stats)),
          const SizedBox(height: 14),
        ],
        section(
          'quick-actions',
          AdminQuickActionsPanel(
            onCreateEvent: controller.navigateToCreateEvent,
            onCreateNews: controller.navigateToCreateNews,
            onNotify: controller.navigateToNotification,
          ),
        ),
        if (eventList.draftEvents.isNotEmpty) ...[
          const SizedBox(height: 14),
          section(
            'drafts',
            AdminDraftsPanel(
              drafts: eventList.draftEvents,
              onTap: controller.navigateToDraft,
            ),
          ),
        ],
        const SizedBox(height: 14),
        section(
          'upcoming',
          AdminUpcomingPanel(
            events: upcoming,
            statsFor: controller.statsFor,
            onTap: controller.navigateToEventDetails,
          ),
        ),
      ],
    );
  }
}
