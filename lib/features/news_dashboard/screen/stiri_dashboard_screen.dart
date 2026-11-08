import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/features/news_dashboard/controller/stiri_dashboard_controller.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_feed.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/state_management/news_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/buttons/tick_outline_button.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/ui/components/feedback/text_input_dialog.dart';
import 'package:teamxperience/ui/components/misc/filter_sheet.dart';
import 'package:teamxperience/ui/components/misc/feed_search_bar.dart';
import 'package:teamxperience/ui/components/misc/removable_chip.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/misc/period_selection.dart';
import 'package:teamxperience/ui/components/misc/period_sheet.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

class StiriDashboard extends StatefulWidget {
  const StiriDashboard({super.key});

  @override
  State<StiriDashboard> createState() => _StiriDashboardState();
}

class _StiriDashboardState extends State<StiriDashboard> {
  static const _typeGroup = 'type';
  static const _categoryGroup = 'category';

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

  bool get _isAdmin =>
      context.read<UserProvider>().currentUser?.role == Role.ADMIN;

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

  /// Admin filters: period, public or private, and category, applied together.
  Future<void> _openAdminFilter() async {
    final news = context.read<NewsList>().stireList;
    // Saved categories plus the ones in use, so a category with no news yet shows too.
    final categories = await controller.categoryNames(news);
    if (!mounted) return;

    final result = await showFilterSheet(
      context,
      groups: [
        FilterGroup(
          id: _typeGroup,
          title: 'Tip știre',
          options: [
            for (final type in StireType.values)
              FilterOption(type.name, type.displayName),
          ],
        ),
        FilterGroup(
          id: _categoryGroup,
          title: 'Categorie',
          options: [for (final name in categories) FilterOption(name, name)],
          addTooltip: 'Adaugă categorie',
          onAdd: () => _addCategory(categories),
          onOptionLongPress:
              (option) => _deleteCategory(option.label, categories, news),
        ),
      ],
      period: PeriodSelection(
        start: controller.startDate,
        end: controller.endDate,
      ),
      selected: {
        if (controller.selectedStireType != null)
          _typeGroup: controller.selectedStireType!.name,
        if (controller.selectedCategory != null &&
            controller.selectedCategory!.name.isNotEmpty)
          _categoryGroup: controller.selectedCategory!.name,
      },
    );
    if (result == null) return;

    final type = result.selected[_typeGroup];
    final category = result.selected[_categoryGroup];
    controller.updateFilters({
      'stireType': type == null ? null : StireType.values.byName(type),
      'category': category == null ? null : NewsCategory(name: category),
      'startDate': result.period.start,
      'endDate': result.period.end,
    });
  }

  /// Asks for a name and saves a new category. [known] holds the names shown in
  /// the sheet and is extended with the new one.
  Future<FilterOption?> _addCategory(List<String> known) async {
    final name = await showTextInputDialog(
      context,
      title: 'Categorie nouă',
      label: 'Nume categorie',
      confirmLabel: 'Adaugă',
    );
    if (name == null || !mounted) return null;

    final result = await controller.addCategory(name, known);
    if (!mounted) return null;

    switch (result.status) {
      case AddCategoryStatus.added:
        known.add(result.name);
        MySnackBars.successSnackBar(
          context,
          title: 'Categoria a fost adăugată',
        );
        return FilterOption(result.name, result.name);
      case AddCategoryStatus.duplicate:
        MySnackBars.warningSnackBar(context, title: 'Categoria există deja');
      case AddCategoryStatus.empty:
        break;
      case AddCategoryStatus.failed:
        MySnackBars.errorSnackBar(
          context,
          title: 'Nu am putut salva categoria',
        );
    }
    return null;
  }

  /// The x on a post (admins): confirm, then delete the news.
  Future<void> _deleteStire(Stire stire) async {
    final id = stire.id;
    if (id == null) return;

    final confirmed = await showAppDialog(
      context,
      title: 'Șterge știrea',
      message:
          'Vrei să ștergi "${stire.title ?? 'această știre'}"? Nu se poate anula.',
      confirmLabel: 'Șterge',
      cancelLabel: 'Anulează',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<NewsList>().deleteStire(id);
      if (!mounted) return;
      MySnackBars.successSnackBar(context, title: 'Știrea a fost ștearsă');
    } catch (_) {
      if (!mounted) return;
      MySnackBars.errorSnackBar(context, title: 'Nu am putut șterge știrea');
    }
  }

  /// Long press on a category: confirm, then delete it. Returns true when it
  /// was deleted, so the sheet drops the chip. [known] is kept in step.
  Future<bool> _deleteCategory(
    String name,
    List<String> known,
    List<Stire> news,
  ) async {
    final confirmed = await showAppDialog(
      context,
      title: 'Șterge categoria',
      message: 'Vrei să ștergi categoria "$name"?',
      confirmLabel: 'Șterge',
      cancelLabel: 'Anulează',
      destructive: true,
    );
    if (!confirmed || !mounted) return false;

    final result = await controller.deleteCategory(name, news);
    if (!mounted) return false;

    switch (result.status) {
      case DeleteCategoryStatus.deleted:
        known.remove(name);
        MySnackBars.successSnackBar(context, title: 'Categoria a fost ștearsă');
        return true;
      case DeleteCategoryStatus.inUse:
        MySnackBars.warningSnackBar(
          context,
          title: 'Categoria nu poate fi ștearsă',
          message:
              result.newsCount == 1
                  ? 'O știre încă o folosește.'
                  : '${result.newsCount} știri încă o folosesc.',
        );
      case DeleteCategoryStatus.notFound:
        MySnackBars.infoSnackBar(context, title: 'Categoria nu este salvată');
      case DeleteCategoryStatus.failed:
        MySnackBars.errorSnackBar(
          context,
          title: 'Nu am putut șterge categoria',
        );
    }
    return false;
  }

  /// Players filter by period only (a bottom sheet); admins keep the full
  /// filter screen with type and category.
  Future<void> _openFilter() async {
    if (_isAdmin) {
      await _openAdminFilter();
      return;
    }

    final picked = await showPeriodSheet(
      context,
      initial: PeriodSelection(
        start: controller.startDate,
        end: controller.endDate,
      ),
    );
    if (picked == null) return;
    controller.updateFilters({
      'stireType': controller.selectedStireType,
      'category': controller.selectedCategory,
      'startDate': picked.start,
      'endDate': picked.end,
    });
  }

  Widget? _createButton() {
    if (!_isAdmin) return null;

    return TickOutlineButton(
      label: 'Creează știre',
      icon: Icons.add_circle_outline,
      onTap: _createStire,
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
          RemovableChip(
            label: type.displayName,
            onRemove: controller.clearStireTypeFilter,
          ),
        if (category != null && category.name.isNotEmpty)
          RemovableChip(
            label: category.name,
            onRemove: controller.clearCategoryFilter,
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

  Widget _header(bool hasFilter) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedSearchBar(
            isSearchOpen: _isSearchOpen,
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            searchHint: 'Caută știri...',
            hasActiveFilters: controller.hasActiveFilters,
            onToggleSearch: _toggleSearch,
            onFilter: _openFilter,
            filterIcon: _isAdmin ? Icons.tune : Icons.calendar_today_outlined,
            filterLabel: _isAdmin ? 'Filtrează' : 'Alege perioada',
            leading: _createButton(),
          ),
          if (hasFilter) ...[const SizedBox(height: 10), _activeChips()],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBarText: 'Știri'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Consumer<NewsList>(
            builder: (context, newsList, child) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final hasFilter =
                      controller.hasActiveFilters ||
                      controller.searchQuery.isNotEmpty;

                  if (newsList.isLoading && newsList.stireList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (newsList.error != null && newsList.stireList.isEmpty) {
                    return LoadFailed(
                      message: 'Nu am putut încărca știrile.',
                      onRetry: () => newsList.loadStire(forceRefresh: true),
                    );
                  }
                  return NewsFeed(
                    header: _header(hasFilter),
                    news: controller.getDisplayedStiri(newsList),
                    onDelete: _isAdmin ? _deleteStire : null,
                    emptyMessage:
                        controller.searchQuery.isNotEmpty
                            ? 'Nu s-au găsit știri'
                            : 'Nu există știri',
                    onTap: _openStire,
                    onShare: _share,
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
