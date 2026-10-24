import 'package:flutter/material.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/components/news/news_post_card.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

/// The vertical feed of news posts.
class NewsFeed extends StatelessWidget {
  const NewsFeed({
    super.key,
    required this.news,
    required this.onTap,
    required this.onShare,
    this.header,
    this.onDelete,
    this.emptyMessage = 'Nu există știri',
  });

  final List<Stire> news;
  final void Function(Stire stire) onTap;
  final void Function(Stire stire) onShare;
  final String emptyMessage;

  /// Scrolls with the posts as the first item (search, filters).
  final Widget? header;

  /// When set (admins), every post gets a small x that calls it.
  final void Function(Stire stire)? onDelete;

  @override
  Widget build(BuildContext context) {
    final remove = onDelete;
    final top = header;
    final offset = top == null ? 0 : 1;

    if (news.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (top != null) top,
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                emptyMessage,
                style: TextStyle(color: context.colors.muted, fontSize: 15),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: news.length + offset,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, listIndex) {
        if (top != null && listIndex == 0) return top;
        final stire = news[listIndex - offset];

        return NewsPostCard(
          title: stire.title ?? '',
          preview: newsPreview(stire),
          categoryLabel: stire.category?.name ?? 'Necategorizat',
          dateLabel: CalendarHelper.formatDate(stire.publicationDate),
          imageUrl: stire.principalImage,
          tag:
              stire.type == StireType.PRIVATA
                  ? StireType.PRIVATA.displayName
                  : null,
          onTap: () => onTap(stire),
          onShare: () => onShare(stire),
          onDelete: remove == null ? null : () => remove(stire),
        );
      },
    );
  }
}
