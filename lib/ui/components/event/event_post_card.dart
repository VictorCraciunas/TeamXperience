import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

/// An event as a feed post: a large poster with the date on it, then the
/// title, place and a details line. The whole post opens the event; the share
/// icon is the only other action.
class EventPostCard extends StatelessWidget {
  const EventPostCard({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.place,
    required this.details,
    required this.onTap,
    required this.onShare,
    this.imageUrl,
    this.tag,
    this.dimmed = false,
  });

  final String title;
  final String dateLabel;
  final String place;
  final String details;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final String? imageUrl;

  /// A small label on the poster, for example "Înscris".
  final String? tag;

  /// Fades the post (events that are over).
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = tag;

    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: Material(
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
              AspectRatio(
                aspectRatio: 1.35,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Poster(imageUrl: imageUrl),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _Chip(text: dateLabel, background: colors.navy),
                    ),
                    if (label != null)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: _Chip(text: label, background: colors.tick),
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
                            style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.muted, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            details,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onShare,
                      tooltip: 'Distribuie',
                      icon: Icon(Icons.share_outlined, color: colors.text, size: 22),
                    ),
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

class _Poster extends StatelessWidget {
  const _Poster({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(color: context.colors.navy);
    final url = imageUrl;
    if (url == null || url.isEmpty) return fallback;

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => fallback,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.background});

  final String text;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
