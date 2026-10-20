import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/features/news_dashboard/controller/stiri_dashboard_controller.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_feed.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/state_management/news_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/components/misc/feed_search_bar.dart';
import 'package:teamxperience/ui/components/misc/removable_chip.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

class StiriDashboard extends StatefulWidget {
  const StiriDashboard({super.key});

  @override
  State<StiriDashboard> createState() => _StiriDashboardState();
}

class _StiriDashboardState extends State<StiriDashboard> {
  late StiriDashboardController controller;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = StiriDashboardController();

    _searchController.addListener(() {
      controller.searchStiri(_searchController.text, context.read<NewsList>());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<NewsList>().loadStire();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  bool get _isAdmin => context.read<UserProvider>().currentUser?.role == Role.ADMIN;

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

  void _openStire(Stire stire) {
    Navigator.pushNamed(
      context,
      Routes.newsDetails,
      arguments: {'stire': stire, 'isAdmin': _isAdmin},
    );
  }

  void _share(Stire stire) {
    ShareService().shareText(
      context,
      subject: stire.title ?? 'Știre',
      text: newsShareText(stire),
    );
  }

  void _createStire() {
    Navigator.pushNamed(context, Routes.createNews, arguments: {'stire': null});
  }

  Future<void> _openFilter() async {
    final filterData = await Navigator.pushNamed(context, Routes.filterStiri) as Map<String, dynamic>?;
    controller.updateFilters(filterData);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget? _createButton() {
    if (!_isAdmin) return null;
    final colors = context.colors;

    return InkWell(
      onTap: _createStire,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: colors.iconButtonBg,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSvgIcon('assets/images/add_icon.svg', width: 20, height: 20, color: colors.accent),
            const SizedBox(width: 8),
            Text('Creează știre', style: TextStyle(fontSize: 15, color: colors.text)),
          ],
        ),
      ),
    );
  }

  Widget _activeChips() {
    final type = controller.selectedStireType;
    final category = controller.selectedCategory;
    final start = controller.startDate;
    final end = controller.endDate;
    final query = controller.searchQuery;

    return Wrap(
      spacing: 8,
      children: [
        if (type != null)
          RemovableChip(label: type.displayName, onRemove: controller.clearStireTypeFilter),
        if (category != null && category.name.isNotEmpty)
          RemovableChip(label: category.name, onRemove: controller.clearCategoryFilter),
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
      appBar: const MyAppBar(appBarText: "Știri"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: 12),
          child: Consumer<NewsList>(
            builder: (context, newsList, child) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final hasFilter = controller.hasActiveFilters || controller.searchQuery.isNotEmpty;

                  return Column(
                    children: [
                      FeedSearchBar(
                        isSearchOpen: _isSearchOpen,
                        searchController: _searchController,
                        searchFocusNode: _searchFocusNode,
                        searchHint: 'Caută știri...',
                        hasActiveFilters: controller.hasActiveFilters,
                        onToggleSearch: _toggleSearch,
                        onFilter: _openFilter,
                        leading: _createButton(),
                      ),
                      if (hasFilter) ...[
                        const SizedBox(height: 10),
                        Align(alignment: Alignment.centerLeft, child: _activeChips()),
                      ],
                      const SizedBox(height: 12),
                      Expanded(
                        child: NewsFeed(
                          news: controller.getDisplayedStiri(newsList),
                          emptyMessage: controller.searchQuery.isNotEmpty ? 'Nu s-au găsit știri' : 'Nu există știri',
                          onTap: _openStire,
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
