import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/features/events_dashboard/events_dashboard_user/controller/events_dash_user_controller.dart';
import 'package:teamxperience/ui/components/misc/custom_icon_dashboard.dart';
import 'package:teamxperience/ui/components/event/registered_events_list.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/routes.dart';
import '../../../../model/event.dart';
import '../../../../state_management/user_registered_events.dart';
import 'package:teamxperience/ui/components/event/events_list.dart';

class FilterEventsUser extends StatefulWidget {
  const FilterEventsUser({super.key});

  @override
  State<FilterEventsUser> createState() => _FilterEventsUserState();
}

class _FilterEventsUserState extends State<FilterEventsUser> with SingleTickerProviderStateMixin {
  late EventsDashboardUserController controller;
  late AnimationController _animationController;
  late Animation<double> _searchAnimation;
  bool _isSearchExpanded = false;
  bool isEvenimente = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();

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
      controller.searchEvents(_searchController.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isControllerInitialized) {
      final events = ModalRoute.of(context)?.settings.arguments as List<Event>;
      controller = EventsDashboardUserController(events, context);
      _isControllerInitialized = true;
    }
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
        'isAdmin': false,
      },
    );
  }
  void _navigateToTeamDetails(Event event) {
    Navigator.pushNamed(
      context,
      Routes.registerTeamDetails,
      arguments: {
        'event': event,
        'user': controller.user,
      },
    );
  }

  void _navigateToFilter(BuildContext context) async {
    final filterData = await Navigator.pushNamed(
      context,
      Routes.filter,
      arguments: false
    ) as Map<String, dynamic>?;
    controller.updateFilters(filterData);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyPaddings.appHorizontalPadding),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Column(
                children: [
                  // Header with back button and action buttons
                  AnimatedBuilder(
                    animation: _searchAnimation,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button
                          if (!_isSearchExpanded)
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: SvgPicture.asset(
                                'assets/images/back.svg',
                                width: 24,
                                height: 24,
                              ),
                            )
                          else
                            const SizedBox(width: 24),

                          // Action buttons and search field
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Search field when expanded


                                // Filter button (always visible, stays on the left)
                                CustomIconDashBoard(
                                  activeFilter: controller.hasActiveFilters,
                                  onTap: () => _navigateToFilter(context),
                                  iconString: 'assets/images/filter.svg',
                                ),
                                if (_isSearchExpanded)
                                  Expanded(
                                    child: Container(
                                      height: 45,
                                      margin: const EdgeInsets.only(left: 16, right: 8),
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
                                  ),

                                // Search button (only when not expanded)
                                if (!_isSearchExpanded) ...[
                                  const SizedBox(width: 10),
                                  CustomIconDashBoard(
                                    activeFilter: false,
                                    onTap: _toggleSearch,
                                    iconString: 'assets/images/search.svg',
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (controller.hasActiveFilters) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
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

                  const SizedBox(height: 20),

                  // Tab selector
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MyColors.transparentLightBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isEvenimente = true;
                                });
                              },
                              child: Container(
                                height: 37,
                                width: double.infinity,
                                decoration: isEvenimente
                                    ? BoxDecoration(
                                  color: MyColors.lightBlue,
                                  borderRadius: BorderRadius.circular(30),
                                )
                                    : null,
                                child: Center(
                                  child: Text(
                                    "Evenimente",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: isEvenimente ? Colors.white : MyColors.blackColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isEvenimente = false;
                              });
                            },
                            child: Container(
                              height: 37,
                              width: double.infinity,
                              decoration: !isEvenimente
                                  ? BoxDecoration(
                                color: MyColors.lightBlue,
                                borderRadius: BorderRadius.circular(30),
                              )
                                  : null,
                              child: Center(
                                child: Text(
                                  "Înscrieri",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: !isEvenimente ? Colors.white : MyColors.blackColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Events list
                  if (isEvenimente)
                    Expanded(
                      child: controller.events.isNotEmpty
                          ? SingleChildScrollView(
                        child: EventsList(
                          events: controller.events,
                          onEventTap: (event) => navigateToEventDetails(context, event),
                          isAdmin: false,
                          shrinkWrap: true,
                          eventStats: controller.eventStats,
                        ),
                      )
                          : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: MyColors.greyText.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.searchQuery.isNotEmpty
                                  ? 'Nu s-au găsit evenimente'
                                  : 'Nu există evenimente',
                              style: TextStyle(
                                fontSize: 16,
                                color: MyColors.greyText.withValues(alpha: 0.7),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Consumer<UserEventsProvider>(
                        builder: (context, userEventsProvider, child) {
                          final filteredUpcoming = controller.filterRegisteredEvents(
                            userEventsProvider.upcomingRegisteredEvents,
                          );
                          final filteredPast = controller.filterRegisteredEvents(
                            userEventsProvider.pastRegisteredEvents,
                          );

                          final hasUpcoming = filteredUpcoming.isNotEmpty;
                          final hasPast = filteredPast.isNotEmpty;

                          if (!hasUpcoming && !hasPast) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 64,
                                    color: MyColors.greyText.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    controller.searchQuery.isNotEmpty || controller.hasActiveFilters
                                        ? 'Nu s-au găsit înscrieri'
                                        : 'Nu există înscrieri',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: MyColors.greyText.withValues(alpha: 0.7),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasUpcoming) ...[
                                  _buildSectionHeader("Înscrieri viitoare"),
                                  RegisteredEventsList(
                                    events: filteredUpcoming,
                                    onEventTap: (event) => _navigateToTeamDetails(event),
                                    shrinkWrap: true,
                                  ),
                                ],
                                if (hasPast) ...[
                                  _buildSectionHeader("Înscrieri trecute"),
                                  RegisteredEventsList(
                                    events: filteredPast,
                                    onEventTap: (event) => _navigateToTeamDetails(event),
                                    shrinkWrap: true,
                                  ),
                                ],
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}