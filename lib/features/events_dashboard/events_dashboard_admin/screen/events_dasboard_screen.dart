import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/widgets/my_appbar.dart';

import '../../../../constants/routes.dart';
import '../../../../enums/event_type.dart';
import '../../../../state_management/events_state_management.dart';
import '../../../../widgets/CustomIconDashboard.dart';
import '../../../../widgets/event_card/events_list.dart';
import '../controller/events_dashboard_controller.dart';

class EventsDashboard extends StatefulWidget {
  const EventsDashboard({super.key});

  @override
  State<EventsDashboard> createState() => _EventsDashboardState();
}

class _EventsDashboardState extends State<EventsDashboard> with SingleTickerProviderStateMixin {
  late EventsDashboardController controller;
  late AnimationController _animationController;
  late Animation<double> _searchAnimation;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = EventsDashboardController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _searchController.addListener(() {
      final eventList = context.read<EventList>();
      controller.searchEvents(_searchController.text, eventList);
    });

    // Load events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventList>().loadEvents();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _animationController.forward();
        _searchFocusNode.requestFocus();
      } else {
        _animationController.reverse();
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

  void navigateToEventDetails(BuildContext context, Event event) {
    Navigator.pushNamed(
      context,
      Routes.eventDetails,
      arguments: {
        'event': event,
        'isAdmin': true,
      },
    );
  }

  void _navigateToCreateEvent(BuildContext context, {Event? event}) {
    Navigator.pushNamed(
      context,
      Routes.createEvent,
      arguments: {'event': event, 'isBlueprint': true},
    );
  }

  void _navigateToFilter(BuildContext context) async {
    final filterData = await Navigator.pushNamed(
      context,
      Routes.filter,
        arguments: true
    ) as Map<String, dynamic>?;

    controller.updateFilters(filterData);
  }

  String _getEventTypeDisplayName(EventType type) {
    switch (type) {
      case EventType.PUBLIC:
        return 'Public';
      case EventType.PRIVAT:
        return 'Privat';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: MyColors.lightBlue,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: MyColors.blackColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: MyColors.lightBlue,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBarText: "Evenimente"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
            vertical: 15,
          ),
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
                      Text('Error: ${eventList.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => eventList.loadEvents(forceRefresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final hasUpcoming = controller.hasUpcomingEvents(eventList);
                  final hasPast = controller.hasPastEvents(eventList);

                  return Column(
                    children: [
                      // Header with buttons and filters (non-scrollable)
                      AnimatedBuilder(
                        animation: _searchAnimation,
                        builder: (context, child) {
                          return Row(
                            children: [
                              // Create event button - can be 45 width or expanded
                              if (!_isSearchExpanded)
                                Expanded(
                                  child: InkWell(
                                    splashFactory: InkSplash.splashFactory,
                                    onTap: () => _navigateToCreateEvent(context),
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: MyColors.transparentLightBlue,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/add_icon.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Creeza eveniment",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: MyColors.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                InkWell(
                                  splashFactory: InkSplash.splashFactory,
                                  onTap: () => _navigateToCreateEvent(context),
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: MyColors.transparentLightBlue,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/images/add_icon.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),

                              // Filter button
                              CustomIconDashBoard(
                                activeFilter: controller.hasActiveFilters,
                                onTap: () => _navigateToFilter(context),
                                iconString: 'assets/images/filter.svg',
                              ),
                              const SizedBox(width: 8),

                              // Search field
                              if (_isSearchExpanded)
                                Expanded(
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: MyColors.transparentLightBlue,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            focusNode: _searchFocusNode,
                                            decoration: const InputDecoration(
                                              hintText: 'Caută evenimente...',
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Poppins',
                                                color: MyColors.greyText,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                              color: MyColors.blackColor,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashFactory: NoSplash.splashFactory,
                                          onTap: _toggleSearch,
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: const BoxDecoration(),
                                            child: const Center(
                                              child: Icon(
                                                Icons.close,
                                                size: 24,
                                                color: MyColors.blackColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                CustomIconDashBoard(
                                  activeFilter: false,
                                  onTap: _toggleSearch,
                                  iconString: 'assets/images/search.svg',
                                ),
                            ],
                          );
                        },
                      ),

                      // Active filters display
                      if (controller.hasActiveFilters) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (controller.selectedEventType != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: MyColors.transparentLightBlue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getEventTypeDisplayName(controller.selectedEventType!),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        color: MyColors.blackColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => controller.clearEventTypeFilter(),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: MyColors.blackColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (controller.startDate != null && controller.endDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: MyColors.transparentLightBlue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_formatDate(controller.startDate!)} - ${_formatDate(controller.endDate!)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        color: MyColors.blackColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => controller.clearDateFilter(),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: MyColors.blackColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],

                      // Search query display
                      if (controller.searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: MyColors.transparentLightBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search,
                                size: 14,
                                color: MyColors.blackColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '"${controller.searchQuery}"',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: MyColors.blackColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _clearSearchQuery,
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: MyColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // SINGLE SCROLLABLE CONTENT WITH COLUMN APPROACH
                      Expanded(
                        child: hasUpcoming || hasPast
                            ? RefreshIndicator(
                          onRefresh: () => eventList.refresh(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Upcoming Events Section
                                if (hasUpcoming) ...[
                                  _buildSectionHeader("Evenimente viitoare"),
                                  // Use EventsList with shrinkWrap: true (Column approach)
                                  EventsList(
                                    events: controller.getDisplayedUpcomingEvents(eventList),
                                    onEventTap: (event) => navigateToEventDetails(context, event),
                                    isAdmin: true,
                                    shrinkWrap: true, // This makes it use Column instead of ListView
                                  ),
                                ],

                                // Past Events Section
                                if (hasPast) ...[
                                  _buildSectionHeader("Evenimente trecute"),
                                  // Use EventsList with shrinkWrap: true (Column approach)
                                  EventsList(
                                    events: controller.getDisplayedPastEvents(eventList),
                                    onEventTap: (event) => navigateToEventDetails(context, event),
                                    isAdmin: true,
                                    shrinkWrap: true, // This makes it use Column instead of ListView
                                  ),
                                ],

                                // Add some bottom padding
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        )
                            : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: MyColors.greyText.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.searchQuery.isNotEmpty
                                    ? 'Nu s-au găsit evenimente'
                                    : 'Nu există evenimente',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: MyColors.greyText.withOpacity(0.7),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              if (!eventList.isLoading)
                                TextButton(
                                  onPressed: () => eventList.loadEvents(forceRefresh: true),
                                  child: const Text('Încarcă evenimente'),
                                ),
                            ],
                          ),
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