import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/events_dashboard/events_dashboard_user/controller/events_dash_user_controller.dart';
import 'package:teamxperience/features/events_dashboard/events_dashboard_user/widgets/events_feed.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/components/misc/choice_chips_row.dart';
import 'package:teamxperience/ui/components/misc/feed_search_bar.dart';
import 'package:teamxperience/ui/components/misc/removable_chip.dart';
import 'package:teamxperience/ui/ui.dart';

class FilterEventsUser extends StatefulWidget {
  const FilterEventsUser({super.key});

  @override
  State<FilterEventsUser> createState() => _FilterEventsUserState();
}

class _FilterEventsUserState extends State<FilterEventsUser> {
  late EventsDashboardUserController controller;
  bool _isSearchOpen = false;
  int _chipIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      controller.searchEvents(_searchController.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArguments = ModalRoute.of(context)?.settings.arguments;
    final routeEvents = routeArguments is List<Event> ? routeArguments : null;
    final events = routeEvents ?? Provider.of<EventList>(context).upcomingEvents;
    if (!_isControllerInitialized) {
      controller = EventsDashboardUserController(events, context);
      _isControllerInitialized = true;
    } else if (routeEvents == null) {
      controller.updateEvents(events);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (_isSearchOpen) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        controller.clearSearch();
        _searchFocusNode.unfocus();
      }
    });
  }

  void _clearSearchQuery() {
    _searchController.clear();
    controller.clearSearch();
  }

  void _openEvent(Event event, Set<String> registeredIds) {
    if (registeredIds.contains(event.eventId)) {
      Navigator.pushNamed(
        context,
        Routes.registerTeamDetails,
        arguments: {'event': event, 'user': controller.user},
      );
      return;
    }
    Navigator.pushNamed(
      context,
      Routes.eventDetails,
      arguments: {'event': event, 'isAdmin': false},
    );
  }

  void _share(Event event) {
    ShareService().shareText(
      context,
      subject: event.name ?? 'Eveniment',
      text: eventShareText(event),
    );
  }

  Future<void> _openFilter() async {
    final filterData = await Navigator.pushNamed(
      context,
      Routes.filter,
      arguments: false,
    ) as Map<String, dynamic>?;
    controller.updateFilters(filterData);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget? _backButton() {
    if (!Navigator.of(context).canPop()) return null;
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Înapoi',
        icon: Icon(Icons.arrow_back, color: context.colors.text),
      ),
    );
  }

  Widget _activeChips() {
    final start = controller.startDate;
    final end = controller.endDate;
    final query = controller.searchQuery;

    return Wrap(
      spacing: 8,
      children: [
        if (start != null && end != null)
          RemovableChip(
            label: '${_formatDate(start)} - ${_formatDate(end)}',
            onRemove: controller.clearDateFilter,
          ),
        if (query.isNotEmpty)
          RemovableChip(label: '"$query"', icon: Icons.search, onRemove: _clearSearchQuery),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Consumer<UserEventsProvider>(
                builder: (context, userEvents, child) {
                  final registeredIds = userEvents.registeredEvents.map((e) => e.eventId).toSet();
                  final onlyRegistered = _chipIndex == 1;
                  final hasFilter = controller.hasActiveFilters || controller.searchQuery.isNotEmpty;

                  final upcoming = onlyRegistered
                      ? controller.filterRegisteredEvents(userEvents.upcomingRegisteredEvents)
                      : controller.events;
                  final past = onlyRegistered
                      ? controller.filterRegisteredEvents(userEvents.pastRegisteredEvents)
                      : <Event>[];

                  return Column(
                    children: [
                      FeedSearchBar(
                        isSearchOpen: _isSearchOpen,
                        searchController: _searchController,
                        searchFocusNode: _searchFocusNode,
                        searchHint: 'Caută evenimente...',
                        hasActiveFilters: controller.hasActiveFilters,
                        onToggleSearch: _toggleSearch,
                        onFilter: _openFilter,
                        leading: _backButton(),
                      ),
                      if (hasFilter) ...[
                        const SizedBox(height: 10),
                        Align(alignment: Alignment.centerLeft, child: _activeChips()),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ChoiceChipsRow(
                          labels: const ['Toate', 'Înscrise'],
                          selectedIndex: _chipIndex,
                          onSelected: (i) => setState(() => _chipIndex = i),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: EventsFeed(
                          upcoming: upcoming,
                          past: past,
                          registeredIds: registeredIds,
                          emptyMessage: onlyRegistered
                              ? (hasFilter ? 'Nu s-au găsit înscrieri' : 'Nu ai nicio înscriere')
                              : (hasFilter ? 'Nu s-au găsit evenimente' : 'Nu există evenimente'),
                          onTap: (event) => _openEvent(event, registeredIds),
                          onShare: _share,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
