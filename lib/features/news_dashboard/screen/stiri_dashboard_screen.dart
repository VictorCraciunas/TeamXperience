import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/widgets/my_appbar.dart';

import '../../../constants/routes.dart';
import '../../../widgets/stire_card/stire_card.dart';
import '../controller/stiri_dashboard_controller.dart';
import '../widgets/appbar.dart';

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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StiriAppBar(
        appBarText: "Știri",
        iconString: 'assets/images/search.svg',
        onIconTap: _toggleSearch,
      ),
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
                  // Search field that appears when icon is tapped
                  AnimatedBuilder(
                    animation: _searchAnimation,
                    builder: (context, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _isSearchExpanded ? 45 : 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _isSearchExpanded ? 1.0 : 0.0,
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
                                    child: Center(
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
                      );
                    },
                  ),
                  if (_isSearchExpanded) const SizedBox(height: 10),
                  if (controller.searchQuery.isNotEmpty) ...[
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
                    const SizedBox(height: 10),
                  ],
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.displayedStiri.length,
                      itemBuilder: (context, index) {
                        final stire = controller.displayedStiri[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: StireCard(
                            stire: stire,
                            onTap: () => navigateToStireDetails(context, stire),
                            isAdmin: true,
                            showBadge: true,
                          ),
                        );
                      },
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