import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/news_dashboard/controller/stiri_dashboard_controller.dart';
import 'package:teamxperience/features/news_dashboard/logic/news_filters.dart';
import 'package:teamxperience/features/news_dashboard/logic/news_texts.dart';
import 'package:teamxperience/features/news_dashboard/widgets/active_news_filters.dart';
import 'package:teamxperience/features/news_dashboard/widgets/admin_news_row.dart';
import 'package:teamxperience/features/news_dashboard/widgets/categories_button.dart';
import 'package:teamxperience/features/news_dashboard/widgets/new_news_bar.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_chips_bar.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_empty.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_header.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_search_field.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_tool_button.dart';
import 'package:teamxperience/model/stire.dart';

/// The organiser's Știri: how many news and categories, the Toate / Publice /
/// Private chips, a row per news with an edit button, and "Știre nouă" at
/// the bottom. Search and the filter sheet (category, period) are the two
/// round buttons by the chips; a long press on a row deletes the news.
class AdminNewsView extends StatelessWidget {
  const AdminNewsView({
    super.key,
    required this.controller,
    required this.news,
    required this.now,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
    required this.onCategories,
    required this.onFilter,
    this.status,
  });

  final StiriDashboardController controller;

  /// Every loaded news; the controller picks what shows.
  final List<Stire> news;
  final DateTime now;
  final void Function(Stire stire) onOpen;
  final void Function(Stire stire) onEdit;
  final void Function(Stire stire) onDelete;
  final VoidCallback onCreate;
  final VoidCallback onCategories;
  final VoidCallback onFilter;

  /// Shown instead of the list (loading, failed to load).
  final Widget? status;

  static const _chipNames = {
    NewsTypeFilter.all: 'Toate',
    NewsTypeFilter.public: 'Publice',
    NewsTypeFilter.private: 'Private',
  };

  @override
  Widget build(BuildContext context) {
    final query = controller.query;
    final counts = controller.counts(news);
    final shown = controller.shown(news);
    final body = status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NewsHeader(
          title: 'Știri',
          subtitle: newsCountLine(news.length, controller.categoriesFor(news).length),
          trailing: CategoriesButton(onTap: onCategories),
        ),
        NewsChipsBar(
          chips: [
            for (final type in NewsTypeFilter.values)
              (
                label: chipLabel(_chipNames[type] ?? '', counts.of(type)),
                selected: query.type == type,
                onTap: () => controller.setType(type),
              ),
          ],
          trailing: [
            NewsToolButton(
              icon: TablerIcons.search,
              tooltip: 'Caută',
              active: controller.searchOpen,
              onTap: controller.toggleSearch,
            ),
            NewsToolButton(
              icon: TablerIcons.adjustments_horizontal,
              tooltip: 'Filtrează',
              active: query.hasCategory || query.hasPeriod,
              onTap: onFilter,
            ),
          ],
        ),
        if (controller.searchOpen) NewsSearchField(initial: query.search, onChanged: controller.setSearch),
        ActiveNewsFilters(
          query: query,
          onClearPeriod: controller.clearPeriod,
          onClearCategory: () => controller.setCategory(null),
        ),
        Expanded(
          child:
              body ??
              (shown.isEmpty
                  ? ListView(
                    children: [
                      NewsEmpty(message: query.hasSearch ? 'Nu s-au găsit știri' : 'Nu există știri'),
                    ],
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    itemCount: shown.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final stire = shown[i];
                      return AdminNewsRow(
                        title: stire.title ?? '',
                        typeLabel: newsTypeLabel(stire),
                        isPrivate: isPrivateNews(stire),
                        meta: adminRowMeta(stire, now),
                        imageUrl: stire.principalImage,
                        onTap: () => onOpen(stire),
                        onEdit: () => onEdit(stire),
                        onDelete: () => onDelete(stire),
                      );
                    },
                  )),
        ),
        NewNewsBar(onTap: onCreate),
      ],
    );
  }
}
