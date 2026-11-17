import 'package:flutter/material.dart';
import 'package:teamxperience/features/news_dashboard/widgets/image_pill.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_thumbnail.dart';
import 'package:teamxperience/ui/ui.dart';

/// The newest news on the player's list, large: the picture with the
/// category (and "Privată" for a private one), the title, a short text and
/// "16 nov · 3 min de citit". The whole card opens the news.
class NewsFeaturedCard extends StatelessWidget {
  const NewsFeaturedCard({
    super.key,
    required this.title,
    required this.preview,
    required this.category,
    required this.meta,
    required this.onTap,
    this.imageUrl,
    this.privateLabel,
  });

  final String title;
  final String preview;
  final String category;
  final String meta;
  final VoidCallback onTap;
  final String? imageUrl;

  /// "Privată" for a private news, null for a public one.
  final String? privateLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final private = privateLabel;

    return Material(
      color: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 176,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NewsThumbnail(url: imageUrl, radius: 0),
                  Positioned(
                    left: 12,
                    top: 12,
                    right: 12,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ImagePill(label: category),
                        if (private != null) ImagePill(label: private),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.35, color: colors.text),
                  ),
                  if (preview.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, height: 1.4, color: colors.muted),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(meta, style: TextStyle(fontSize: 12, color: colors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
