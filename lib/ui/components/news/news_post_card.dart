import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

/// A news item as a feed post: category and date, image, title and a short
/// preview. The whole post opens the item; the share icon is the only other
/// action.
class NewsPostCard extends StatelessWidget {
  const NewsPostCard({
    super.key,
    required this.title,
    required this.preview,
    required this.categoryLabel,
    required this.dateLabel,
    required this.onTap,
    required this.onShare,
    this.imageUrl,
    this.tag,
    this.onDelete,
  });

  final String title;
  final String preview;
  final String categoryLabel;
  final String dateLabel;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final String? imageUrl;

  /// A small label on the image, for example "Privată".
  final String? tag;

  /// When set (admins), a small x in the top right of the image calls it.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = imageUrl;
    final label = tag;
    final delete = onDelete;
    final fallback = ColoredBox(color: colors.navy);

    return Material(
      color: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                delete == null ? 10 : 2,
                delete == null ? 14 : 4,
                delete == null ? 8 : 0,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      categoryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '  ·  ',
                    style: TextStyle(color: colors.muted, fontSize: 12),
                  ),
                  Text(
                    dateLabel,
                    maxLines: 1,
                    style: TextStyle(color: colors.muted, fontSize: 12),
                  ),
                  if (delete != null) ...[
                    const Spacer(),
                    Tooltip(
                      message: 'Șterge știrea',
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: delete,
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: colors.danger,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 1.6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  (url == null || url.isEmpty)
                      ? fallback
                      : CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => fallback,
                        errorWidget: (_, __, ___) => fallback,
                      ),
                  if (label != null)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.navy,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.muted,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onShare,
                    tooltip: 'Distribuie',
                    icon: Icon(
                      Icons.share_outlined,
                      color: colors.text,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
