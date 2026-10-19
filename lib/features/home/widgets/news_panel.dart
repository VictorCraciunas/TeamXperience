import 'package:flutter/material.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';
import 'package:teamxperience/ui/components/news/stiri_carousel.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

class NewsPanel extends StatelessWidget {
  const NewsPanel({
    super.key,
    required this.news,
    required this.onTap,
    required this.onSeeAll,
  });

  final List<Stire> news;
  final void Function(Stire stire) onTap;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Noutăți',
      onAction: news.isEmpty ? null : onSeeAll,
      child: news.isEmpty
          ? Text(
              'Nu sunt știri momentan.',
              style: TextStyle(color: context.colors.muted, fontSize: 12),
            )
          : StiriCarousel(stiri: news, onStireTap: onTap, showBadge: false),
    );
  }
}
