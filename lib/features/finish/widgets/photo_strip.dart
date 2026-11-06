import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The team's photos on the finish screen (mockup 08): up to three 64 px
/// tiles; with more, the third says "+N".
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final extra = urls.length > 3 ? urls.length - 2 : 0;
    final shown = extra > 0 ? urls.take(2).toList() : urls.take(3).toList();

    Widget tile(Widget child) => Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(height: 64, child: child),
          ),
        );

    return Row(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          tile(Image.network(
            shown[i],
            key: const ValueKey('photo-tile'),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => ColoredBox(color: palette.ink.withValues(alpha: .15)),
          )),
        ],
        if (extra > 0) ...[
          const SizedBox(width: 6),
          tile(ColoredBox(
            color: palette.secondaryAccent,
            child: Center(
              child: Text(
                '+$extra',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: palette.onAccent),
              ),
            ),
          )),
        ],
        // Keep the tiles their mockup width when there are fewer than three.
        for (var i = shown.length + (extra > 0 ? 1 : 0); i < 3; i++) ...[
          const SizedBox(width: 6),
          const Expanded(child: SizedBox(height: 64)),
        ],
      ],
    );
  }
}
