import 'package:flutter/material.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// A team's photos in a row: up to three tiles with what each one shows; with
/// more, the third says "+N".
class AlbumStrip extends StatelessWidget {
  const AlbumStrip({super.key, required this.photos, this.onTap});

  final List<AlbumPhoto> photos;

  /// Opens a photo; the "+N" tile opens the first one it stands for.
  final ValueChanged<AlbumPhoto>? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final extra = photos.length > 3 ? photos.length - 2 : 0;
    final shown = extra > 0 ? photos.take(2).toList() : photos.take(3).toList();
    final tap = onTap;

    Widget tile(AlbumPhoto photo, Widget child) => Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: tap == null ? null : () => tap(photo),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(height: 72, child: child),
            ),
          ),
        );

    return Row(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          tile(shown[i], _PhotoTile(photo: shown[i])),
        ],
        if (extra > 0) ...[
          const SizedBox(width: 6),
          tile(
            photos[2],
            ColoredBox(
              color: palette.secondaryAccent,
              child: Center(
                child: Text(
                  '+$extra',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: palette.onAccent),
                ),
              ),
            ),
          ),
        ],
        // Keep the tiles the same width when there are fewer than three.
        for (var i = shown.length + (extra > 0 ? 1 : 0); i < 3; i++) ...[
          const SizedBox(width: 6),
          const Expanded(child: SizedBox(height: 72)),
        ],
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo});

  final AlbumPhoto photo;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final label = photo.label;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          photo.url,
          key: const ValueKey('photo-tile'),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => ColoredBox(color: palette.ink.withValues(alpha: .15)),
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
