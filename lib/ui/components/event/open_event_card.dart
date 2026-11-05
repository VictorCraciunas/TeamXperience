import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';
import '../layout/outline_card.dart';
import '../route/dashed_line.dart';

/// An event open for sign-up, as mockup 03: a 92 px picture strip with an
/// optional amber badge and a share button, then the name and a route row
/// (pin, date, dashed line, length and duration).
class OpenEventCard extends StatelessWidget {
  const OpenEventCard({
    super.key,
    this.imageUrl,
    this.badge,
    required this.title,
    required this.date,
    required this.facts,
    required this.onTap,
    required this.onShare,
  });

  final String? imageUrl;
  final String? badge;
  final String title;
  final String date;
  final String facts;
  final VoidCallback onTap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = imageUrl ?? '';
    final pill = badge;
    final small = TextStyle(fontSize: 11, height: 1.45, color: colors.muted);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: OutlineCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const ValueKey('card-strip'),
              height: 92,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: colors.accent),
                  if (url.startsWith('http'))
                    CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, errorWidget: (_, _, _) => const SizedBox.shrink()),
                  if (pill != null)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: colors.soon, borderRadius: BorderRadius.circular(AppRadius.pill)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                          child: Text(
                            pill,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, color: colors.onTick),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      key: const ValueKey('card-share'),
                      onTap: onShare,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(color: colors.heroButton, shape: BoxShape.circle),
                        child: Icon(TablerIcons.share, size: 14, color: colors.text),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle(context)),
                  const SizedBox(height: 4),
                  // The texts take what they need, capped so a narrow phone
                  // shortens them instead of overflowing; the dashed line takes
                  // the rest, so the facts sit at the right edge. (A Flexible
                  // would leave its unused share blank.)
                  LayoutBuilder(
                    builder: (context, box) {
                      Widget capped(String text, double share) => ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: box.maxWidth * share),
                            child: Text(text, style: small, maxLines: 1, overflow: TextOverflow.ellipsis),
                          );
                      return Row(
                        children: [
                          Icon(TablerIcons.map_pin, size: 13, color: colors.accent),
                          const SizedBox(width: 6),
                          capped(date, 0.45),
                          const SizedBox(width: 6),
                          const Expanded(child: DashedLine()),
                          if (facts.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            capped(facts, 0.4),
                          ],
                        ],
                      );
                    },
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
