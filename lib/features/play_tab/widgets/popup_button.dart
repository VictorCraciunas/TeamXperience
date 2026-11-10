import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

enum PopupButtonKind { navy, tick, outline, link }

/// A button of the Joacă pop-up (mockup 10): 48 px tall, 14 px corners,
/// 15 px semibold; the link kind is a 44 px text button.
class PopupButton extends StatelessWidget {
  const PopupButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = PopupButtonKind.navy,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final PopupButtonKind kind;

  /// Drawn before the label; a widget so it can spin ("Alt joc").
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fill, text, border) = switch (kind) {
      PopupButtonKind.navy => (colors.navy, colors.onNavy, null),
      PopupButtonKind.tick => (colors.tick, colors.onTick, null),
      PopupButtonKind.outline => (colors.panel, colors.text, colors.border),
      PopupButtonKind.link => (null, colors.accent, null),
    };
    final link = kind == PopupButtonKind.link;
    final style = TextStyle(
      fontSize: link ? 14 : 15,
      height: 1.3,
      fontWeight: link ? FontWeight.w500 : FontWeight.w600,
      color: text,
    );
    final lead = icon;

    return Material(
      color: fill ?? colors.panel.withValues(alpha: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: border == null ? BorderSide.none : BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: link ? 44 : 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (lead != null) ...[
                  IconTheme(data: IconThemeData(size: 18, color: text), child: lead),
                  const SizedBox(width: 8),
                ],
                Flexible(child: Text(label, textAlign: TextAlign.center, style: style)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
