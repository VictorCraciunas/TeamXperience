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
    this.emptyMessage = 'Nu există știri',
  });

  final List<Stire> news;
  final void Function(Stire stire) onTap;
  final void Function(Stire stire) onShare;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: TextStyle(color: context.colors.muted, fontSize: 15)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: news.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final stire = news[index];

        return NewsPostCard(
          title: stire.title ?? '',
          preview: newsPreview(stire),
          categoryLabel: stire.category?.name ?? 'Necategorizat',
          dateLabel: CalendarHelper.formatDate(stire.publicationDate),
          imageUrl: stire.principalImage,
          tag: stire.type == StireType.PRIVATA ? StireType.PRIVATA.displayName : null,
          onTap: () => onTap(stire),
          onShare: () => onShare(stire),
        );
      },
    );
  }
}
