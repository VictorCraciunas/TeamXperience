import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/profile/logic/profile_texts.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// One past game in "Amintiri" (mockup 08): a 40 px picture, the event's name,
/// "Locul 2 · 1:48 · 6 poze" and a chevron.
class MemoryCard extends StatelessWidget {
  const MemoryCard({super.key, required this.memory, this.imageUrl, this.photoCount, required this.onTap});

  final Memory memory;

  /// The picture to show; by default the memory's first stored photo.
  final String? imageUrl;

  /// How many photos the game has; by default the stored ones.
  final int? photoCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final line = memoryLine(memory, photoCount: photoCount);
    final stored = memory.photoUrls;
    final picture = imageUrl ?? (stored.isEmpty ? null : stored.first);
    final stand = ColoredBox(
      color: colors.inset,
      child: Center(child: Icon(TablerIcons.map_2, size: 18, color: colors.muted)),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: OutlineCard(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                key: const ValueKey('memory-thumb'),
                dimension: 40,
                child: picture == null
                    ? stand
                    : CachedNetworkImage(
                        imageUrl: picture,
                        fit: BoxFit.cover,
                        memCacheWidth: (60 * MediaQuery.devicePixelRatioOf(context)).round(),
                        errorWidget: (_, _, _) => stand,
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.eventName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
                  ),
                  if (line.isNotEmpty)
                    Text(line, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(TablerIcons.chevron_right, size: 16, color: colors.muted),
          ],
        ),
      ),
    );
  }
}
