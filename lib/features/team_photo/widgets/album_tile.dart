import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// One team photo, with a small pill saying when it was taken.
class AlbumTile extends StatelessWidget {
  const AlbumTile({super.key, required this.photo});

  final AlbumPhoto photo;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final label = photo.label;
    return Stack(
      fit: StackFit.expand,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            // Originals can be many megapixels; decode only what the tile shows.
            final side = math.max(box.maxWidth, box.maxHeight) * 1.5 * MediaQuery.devicePixelRatioOf(context);
            return CachedNetworkImage(
              key: const ValueKey('photo-tile'),
              imageUrl: photo.url,
              fit: BoxFit.cover,
              memCacheWidth: side.isFinite ? side.round() : null,
              errorWidget: (_, _, _) => ColoredBox(color: palette.ink.withValues(alpha: .15)),
            );
          },
        ),
        if (label != null)
          Positioned(
            left: 4,
            right: 4,
            bottom: 4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(99)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, height: 1.45, color: palette.ink),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
