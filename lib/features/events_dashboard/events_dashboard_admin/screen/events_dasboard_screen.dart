import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/admin/create_event/start/open_create_event_flow.dart';
import 'package:teamxperience/features/events_dashboard/events_dashboard_admin/controller/events_dashboard_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/ui/components/buttons/tick_outline_button.dart';
import 'package:teamxperience/ui/components/event/events_list.dart';
import 'package:teamxperience/ui/components/misc/feed_search_bar.dart';
import 'package:teamxperience/ui/components/misc/filter_sheet.dart';
import 'package:teamxperience/ui/components/misc/period_selection.dart';
import 'package:teamxperience/ui/components/misc/removable_chip.dart';
import 'package:teamxperience/ui/components/misc/section_title.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

class EventsDashboard extends StatefulWidget {
  const EventsDashboard({super.key});

  @override
  State<EventsDashboard> createState() => _EventsDashboardState();
}

class _EventsDashboardState extends State<EventsDashboard> {
  static const _typeGroup = 'type';
  static const _statusGroup = 'status';

  late EventsDashboardController controller;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = EventsDashboardController();

    _searchController.addListener(() {
      controller.searchEvents(
        _searchController.text,
        context.read<EventList>(),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final eventList = context.read<EventList>();
      await eventList.loadEvents();
      await controller.loadEventStats([
        ...eventList.upcomingEvents,
        ...eventList.pastEvents,
      ]);
    });
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
      if (!_isSearchOpen) {
        _searchController.clear();
        controller.clearSearch();
      }
    });
  }

  void _clearSearchQuery() {
    _searchController.clear();
    controller.clearSearch();
  }

  void _openEvent(Event event) {
    Navigator.pushNamed(
      context,
      Routes.eventDetails,
      arguments: {'event': event, 'isAdmin': true},
    );
  }

  void _createEvent() {
    openCreateEventFlow(context);
  }

  Future<void> _openFilter() async {
    final result = await showFilterSheet(
      context,
      groups: const [
        FilterGroup(
          id: _typeGroup,
          title: 'Tip eveniment',
          options: [
            FilterOption('PUBLIC', 'Public'),
            FilterOption('PRIVAT', 'Privat'),
          ],
        ),
        FilterGroup(
          id: _statusGroup,
          title: 'Stare',
          options: [
            FilterOption('upcoming', 'Viitoare'),
            FilterOption('past', 'Trecute'),
          ],
        ),
      ],
      period: PeriodSelection(
        start: controller.startDate,
        end: controller.endDate,
      ),
      selected: {
        if (controller.selectedEventType != null)
          _typeGroup: controller.selectedEventType!.name,
        if (controller.selectedStatus != null)
          _statusGroup: controller.selectedStatus!.name,
      },
    );
    if (result == null) return;

    final type = result.selected[_typeGroup];
    final status = result.selected[_statusGroup];
    controller.updateFilters({
      'eventType': type == null ? null : EventType.values.byName(type),
      'status': status == null ? null : EventStatusFilter.values.byName(status),
      'startDate': result.period.start,
      'endDate': result.period.end,
    });
  }

  String _typeLabel(EventType type) =>
      type == EventType.PUBLIC ? 'Public' : 'Privat';

  Widget _activeChips() {
    final type = controller.selectedEventType;
    final status = controller.selectedStatus;
    final start = controller.startDate;
    final end = controller.endDate;
    final query = controller.searchQuery;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (type != null)
          RemovableChip(
            label: _typeLabel(type),
            onRemove: controller.clearEventTypeFilter,
          ),
        if (status != null)
          RemovableChip(
            label:
                status == EventStatusFilter.upcoming ? 'Viitoare' : 'Trecute',
            onRemove: controller.clearStatusFilter,
          ),
        if (start != null && end != null)
          RemovableChip(
            label:
                '${CalendarHelper.formatDate(start)} - ${CalendarHelper.formatDate(end)}',
            onRemove: controller.clearDateFilter,
          ),
        if (query.isNotEmpty)
          RemovableChip(
            label: '"$query"',
            icon: Icons.search,
            onRemove: _clearSearchQuery,
          ),
      ],
    );
  }

  Widget _header() {
    final hasFilter =
        controller.hasActiveFilters || controller.searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedSearchBar(
            isSearchOpen: _isSearchOpen,
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            searchHint: 'Caută evenimente...',
            hasActiveFilters: controller.hasActiveFilters,
            onToggleSearch: _toggleSearch,
            onFilter: _openFilter,
            leading: TickOutlineButton(
              label: 'Creează eveniment',
              icon: Icons.add_circle_outline,
              onTap: _createEvent,
            ),
          ),
          if (hasFilter) ...[const SizedBox(height: 10), _activeChips()],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBarText: 'Evenimente'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Consumer<EventList>(
            builder: (context, eventList, child) {
              if (eventList.isLoading && !eventList.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (eventList.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nu am putut încărca evenimentele.',
                        style: TextStyle(color: context.colors.text),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed:
                            () => eventList.loadEvents(forceRefresh: true),
                        child: const Text('Reîncearcă'),
                      ),
                    ],
                  ),
                );
              }

              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final upcoming = controller.getDisplayedUpcomingEvents(
                    eventList,
                  );
                  final past = controller.getDisplayedPastEvents(eventList);

                  return RefreshIndicator(
                    onRefresh: () => eventList.refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        _header(),
                        if (upcoming.isEmpty && past.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Center(
                              child: Text(
                                controller.searchQuery.isNotEmpty ||
                                        controller.hasActiveFilters
                                    ? 'Nu s-au găsit evenimente'
                                    : 'Nu există evenimente',
                                style: TextStyle(
                                  color: context.colors.muted,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        if (upcoming.isNotEmpty) ...[
                          const SectionTitle('Evenimente viitoare'),
                          EventsList(
                            events: upcoming,
                            onEventTap: _openEvent,
                            isAdmin: true,
                            shrinkWrap: true,
                            eventStats: controller.eventStats,
                          ),
                        ],
                        if (past.isNotEmpty) ...[
                          const SectionTitle('Evenimente trecute'),
                          EventsList(
                            events: past,
                            onEventTap: _openEvent,
                            isAdmin: true,
                            shrinkWrap: true,
                            eventStats: controller.eventStats,
                          ),
                        ],
                      ],
                    ),
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
