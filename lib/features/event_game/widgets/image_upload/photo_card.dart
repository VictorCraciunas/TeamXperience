import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The photo card of mockup 07 (`.pc`, padding 8): the 150 px picture (or a
/// prompt to take it), "Refă" on top of it, then whatever goes under it.
class PhotoCard extends StatelessWidget {
  const PhotoCard({super.key, this.picture, this.onTake, this.onRedo, this.below = const []});

  /// The photo sent (or being sent); null shows the prompt.
  final ImageProvider? picture;

  /// Taps on the empty prompt; null when there is a picture.
  final VoidCallback? onTake;

  /// "Refă"; hidden when null.
  final VoidCallback? onRedo;
  final List<Widget> below;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final image = picture;
    final redo = onRedo;
    final take = onTake;

    final Widget frame;
    if (image != null) {
      frame = Image(
        image: image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: palette.ink.withValues(alpha: .08),
          child: Center(child: Icon(TablerIcons.photo_off, size: 28, color: palette.muted)),
        ),
      );
    } else if (take != null) {
      frame = GestureDetector(
        key: const ValueKey('photo-prompt'),
        behavior: HitTestBehavior.opaque,
        onTap: take,
        child: ColoredBox(
          color: palette.ink.withValues(alpha: .08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(TablerIcons.camera, size: 30, color: palette.accent),
              const SizedBox(height: 6),
              Text('Atinge ca să faci poza', style: TextStyle(fontSize: 12, height: 1.45, color: palette.muted)),
            ],
          ),
        ),
      );
    } else {
      frame = ColoredBox(
        color: palette.ink.withValues(alpha: .08),
        child: Center(child: Icon(TablerIcons.photo, size: 28, color: palette.muted)),
      );
    }

    return DecoratedBox(
      key: const ValueKey('photo-card'),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        // The mockup's 8, plus the 1 px border drawn inside.
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    frame,
                    if (redo != null)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: redo,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: palette.surface.withValues(alpha: .92),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(TablerIcons.refresh, size: 12, color: palette.ink),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Refă',
                                    style: TextStyle(fontSize: 11, height: 1.45, fontWeight: FontWeight.w500, color: palette.ink),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ...below,
          ],
        ),
      ),
    );
  }
}
