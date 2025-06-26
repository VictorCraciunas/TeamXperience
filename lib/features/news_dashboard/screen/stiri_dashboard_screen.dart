import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/widgets/my_appbar.dart';

import '../../../constants/routes.dart';
import '../../../widgets/stire_card/stire_card.dart';
import '../controller/stiri_dashboard_controller.dart';

class StiriDashboard extends StatefulWidget {
  const StiriDashboard({super.key});

  @override
  State<StiriDashboard> createState() => _StiriDashboardState();
}

class _StiriDashboardState extends State<StiriDashboard> with SingleTickerProviderStateMixin {
  late StiriDashboardController controller;
  late AnimationController _animationController;
  late Animation<double> _searchAnimation;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = StiriDashboardController();

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
      controller.searchStiri(_searchController.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get stiri from route arguments
    final stiri = ModalRoute.of(context)?.settings.arguments as List<Stire>?;
    controller.initializeStiri(stiri);
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

  void navigateToStireDetails(BuildContext context, Stire stire) {
    Navigator.pushNamed(
        context,
        Routes.newsDetails,
        arguments: stire
    );
  }

  void _navigateToCreateStire(BuildContext context, {Stire? stire}) {
    Navigator.pushNamed(
      context,
      Routes.createNews, // Assuming you have this route
      arguments: {'stire': stire},
    );
  }

  void _navigateToFilter(BuildContext context) async {
    final filterData = await Navigator.pushNamed(
      context,
      Routes.filterStiri, // New route we'll create
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

  Widget _buildStiriList(List<Stire> stiri) {
    return Column(
      children: stiri.map((stire) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () => navigateToStireDetails(context, stire),
            child: StireCard(
              stire: stire,
              onTap: () => navigateToStireDetails(context, stire),
              isAdmin: true,
              showBadge: true,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBarText: "Știri"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
            vertical: 15,
          ),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Column(
                children: [
                  // Header with buttons and filters (non-scrollable)
                  AnimatedBuilder(
                    animation: _searchAnimation,
                    builder: (context, child) {
                      return Row(
                        children: [
                          // Create stire button - can be 45 width or expanded
                          if (!_isSearchExpanded)
                            Expanded(
                              child: InkWell(
                                splashFactory: InkSplash.splashFactory,
                                onTap: () => _navigateToCreateStire(context),
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
                                        "Creează știre",
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
                              onTap: () => _navigateToCreateStire(context),
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

                          // Filter button - stays the same
                          InkWell(
                            splashFactory: InkSplash.splashFactory,
                            onTap: () => _navigateToFilter(context),
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: controller.hasActiveFilters
                                    ? MyColors.lightBlue
                                    : MyColors.transparentLightBlue,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/filter.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: controller.hasActiveFilters
                                      ? const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Search field - can be 45 width or expanded
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
                                          hintText: 'Caută știri...',
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
                            InkWell(
                              splashFactory: InkSplash.splashFactory,
                              onTap: _toggleSearch,
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: MyColors.transparentLightBlue,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/images/search.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
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
                        if (controller.selectedStireType != null)
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
                                  controller.selectedStireType!.displayName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    color: MyColors.blackColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => controller.clearStireTypeFilter(),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: MyColors.blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (controller.selectedCategory != null)
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
                                  controller.selectedCategory!.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    color: MyColors.blackColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => controller.clearCategoryFilter(),
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

                  // Scrollable content area
                  Expanded(
                    child: controller.hasRecentStiri || controller.hasOlderStiri
                        ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recent Stiri Section
                          if (controller.hasRecentStiri) ...[
                            _buildSectionHeader("Știri recente"),
                            _buildStiriList(controller.displayedRecentStiri),
                          ],

                          // Older Stiri Section
                          if (controller.hasOlderStiri) ...[
                            _buildSectionHeader("Știri mai vechi"),
                            _buildStiriList(controller.displayedOlderStiri),
                          ],

                          // Add some bottom padding
                          const SizedBox(height: 20),
                        ],
                      ),
                    )
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: MyColors.greyText.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.searchQuery.isNotEmpty
                                ? 'Nu s-au găsit știri'
                                : 'Nu există știri',
                            style: TextStyle(
                              fontSize: 16,
                              color: MyColors.greyText.withOpacity(0.7),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}