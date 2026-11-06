import 'package:flutter/material.dart';

import '../../theme/event_theme_scope.dart';

/// The outlined button of the puzzle bar ("Indiciu", mockup 06): a 1.5 px
/// accent border, radius 12, padding 10, a w500 accent label with a 15 px
/// icon. Greyed (50 %) when [onTap] is null.
class GameOutlineButton extends StatelessWidget {
  const GameOutlineButton({super.key, required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final glyph = icon;
    return Opacity(
      opacity: onTap == null ? .5 : 1,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DecoratedBox(
            key: const ValueKey('game-outline-button'),
            decoration: BoxDecoration(
              border: Border.all(color: palette.accent, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              // The mockup's 10, plus the 1.5 px border drawn inside.
              padding: const EdgeInsets.all(11.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (glyph != null) ...[
                    Icon(glyph, size: 15, color: palette.accent),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: palette.accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
