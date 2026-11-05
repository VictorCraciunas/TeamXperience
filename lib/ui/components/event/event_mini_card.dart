import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import '../layout/outline_card.dart';

/// A small event card for a sideways list, as mockup 02's "Evenimente noi":
/// a `.card` 150 px inside (176 with its 12 px padding and border), a 70 px
/// picture strip pulled 4 / 6 px into the padding with a date pill at its
/// bottom-left, then the name and the route facts.
class EventMiniCard extends StatelessWidget {
  const EventMiniCard({
    super.key,
    required this.title,
    required this.date,
    required this.facts,
    this.imageUrl,
    required this.onTap,
  });

  final String title;
  final String date;
  final String facts;
  final String? imageUrl;
  final VoidCallback onTap;

  /// The card's whole width: 150 + 2 × 12 padding + 2 × 1 border.
  static const double width = 176;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = imageUrl ?? '';
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: OutlineCard(
          // The CSS padding 10 / 12 less the strip's -4 / -6 margins.
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                key: const ValueKey('mini-strip'),
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 70,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: colors.accent),
                      if (url.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const SizedBox.shrink(),
                        ),
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: colors.panel, borderRadius: BorderRadius.circular(99)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                            child: Text(date, style: TextStyle(fontSize: 11, height: 1.45, color: colors.text)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
                    ),
                    Text(
                      facts,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted),
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
