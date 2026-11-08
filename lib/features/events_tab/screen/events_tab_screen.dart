import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/events_tab/controller/events_tab_controller.dart';
import 'package:teamxperience/features/events_tab/widgets/events_map.dart';
import 'package:teamxperience/features/events_tab/widgets/events_tab_view.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';

/// The Evenimente tab of the player shell (mockup 03, left phone).
class EventsTabScreen extends StatefulWidget {
  const EventsTabScreen({super.key});

  @override
  State<EventsTabScreen> createState() => _EventsTabScreenState();
}

class _EventsTabScreenState extends State<EventsTabScreen> {
  EventsTabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final eventList = context.read<EventList>();
    final users = context.read<UserProvider>();
    _controller = EventsTabController(
      events: () => eventList.events,
      registeredIds: () => users.currentUser?.registeredEventIds.toSet() ?? const {},
      uid: () => users.currentUser?.uid,
      source: Listenable.merge([eventList, users]),
      teams: TeamService(),
    );
    eventList.loadEvents();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _open(Event e) =>
      Navigator.pushNamed(context, Routes.eventDetails, arguments: {'event': e, 'isAdmin': false});

  void _share(Event e) =>
      ShareService().shareText(context, subject: e.name ?? 'Eveniment', text: eventShareText(e));

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => EventsTabView(
        failed: context.watch<EventList>().loadFailed,
        loading: context.watch<EventList>().firstLoading,
        sections: controller.sections,
        query: controller.query,
        mapMode: controller.mapMode,
        searching: controller.searching,
        teamNames: controller.teamNames,
        teamCounts: controller.teamCounts,
        now: controller.now,
        onToggle: controller.toggle,
        onAll: controller.selectAll,
        onSearch: controller.setSearch,
        onToggleSearch: controller.toggleSearch,
        onMode: controller.setMapMode,
        onOpen: _open,
        onShare: _share,
        onRefresh: () => context.read<EventList>().loadEvents(forceRefresh: true),
        map: EventsMap(
          events: [...controller.sections.registered, ...controller.sections.open, ...controller.sections.soon],
          registeredIds: controller.registeredIds,
          onOpen: _open,
        ),
      ),
    );
  }
}
