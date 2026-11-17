import 'package:flutter/material.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_thumbnail.dart';
import 'package:teamxperience/ui/ui.dart';

/// A news on the player's list after the featured one: picture, category,
/// title and date. The whole row opens the news.
class NewsRow extends StatelessWidget {
  const NewsRow({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.onTap,
    this.imageUrl,
  });

  final String title;

  /// "Evenimente", or "Evenimente · Privată" for a private news.
  final String category;
  final String date;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              NewsThumbnail(url: imageUrl, width: 76, height: 76),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.accent),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.35, color: colors.text),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(date, style: TextStyle(fontSize: 12, color: colors.muted)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
