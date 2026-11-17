import 'package:flutter/material.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/features/news_dashboard/controller/stiri_dashboard_controller.dart';
import 'package:teamxperience/features/news_dashboard/logic/news_filters.dart';
import 'package:teamxperience/features/news_dashboard/logic/news_texts.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_chips_bar.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_empty.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_featured_card.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_header.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_row.dart';
import 'package:teamxperience/model/stire.dart';

/// The player's Știri: chips by category, the newest news large, then the
/// rest as rows (design News-Player: no search or period filter).
class PlayerNewsView extends StatelessWidget {
  const PlayerNewsView({
    super.key,
    required this.controller,
    required this.news,
    required this.now,
    required this.onOpen,
    this.status,
  });

  final StiriDashboardController controller;

  /// Every loaded news; the controller picks what shows.
  final List<Stire> news;
  final DateTime now;
  final void Function(Stire stire) onOpen;

  /// Shown instead of the list (loading, failed to load).
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    final query = controller.query;
    final selected = query.hasCategory ? query.category : null;
    final shown = controller.shown(news);
    final split = splitFeatured(shown);
    final featured = split.featured;
    final body = status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NewsHeader(title: 'Știri'),
        NewsChipsBar(
          chips: [
            (label: 'Toate', selected: selected == null, onTap: () => controller.setCategory(null)),
            for (final name in controller.playerCategories(news))
              (
                label: name,
                selected: name.toLowerCase() == selected?.trim().toLowerCase(),
                onTap: () => controller.setCategory(name),
              ),
          ],
        ),
        Expanded(
          child:
              body ??
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  if (featured == null)
                    const NewsEmpty(message: 'Nu există știri')
                  else
                    NewsFeaturedCard(
                      title: featured.title ?? '',
                      preview: newsPreview(featured),
                      category: newsCategoryText(featured),
                      meta: featuredMeta(featured, now),
                      imageUrl: featured.principalImage,
                      privateLabel: isPrivateNews(featured) ? StireType.PRIVATA.displayName : null,
                      onTap: () => onOpen(featured),
                    ),
                  for (final stire in split.rest) ...[
                    const SizedBox(height: 10),
                    NewsRow(
                      title: stire.title ?? '',
                      category: playerRowCategory(stire),
                      date: newsDateText(stire.publicationDate, now),
                      imageUrl: stire.principalImage,
                      onTap: () => onOpen(stire),
                    ),
                  ],
                ],
              ),
        ),
      ],
    );
  }
}
