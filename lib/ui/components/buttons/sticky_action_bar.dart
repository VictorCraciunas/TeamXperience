import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'bar_tone.dart';
import 'sticky_bar_button.dart';
import 'sticky_bar_link.dart';
import 'sticky_bar_texts.dart';

/// The bar pinned to the bottom of a page, with a short status on the left
/// and one action on the right ("Mai sunt 5 zile · Înscrie echipa").
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({
    super.key,
    required this.title,
    this.detail,
    this.inlineDetail = false,
    this.leadingIcon,
    this.tone = BarTone.neutral,
    this.highlighted = false,
    this.actionLabel,
    this.actionIcon,
    this.prominent = true,
    this.onAction,
  });

  final String title;
  final String? detail;

  /// Puts [detail] after the title on one line ("Vulpile · 4 membri")
  /// instead of on a second line.
  final bool inlineDetail;
  final IconData? leadingIcon;
  final BarTone tone;

  /// A teal top border, for a bar that asks for action now.
  final bool highlighted;
  /// Null shows the status alone, with no button or link.
  final String? actionLabel;
  final IconData? actionIcon;

  /// A navy button when true, an accent text link when false.
  final bool prominent;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = leadingIcon;
    final label = actionLabel;
    final iconColor = switch (tone) {
      BarTone.success => colors.success,
      BarTone.accent => colors.accent,
      BarTone.neutral => colors.muted,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: highlighted ? colors.tick : colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            // The top border is drawn inside the box, so 1 more than the
            // mockup's 10 keeps the content where the CSS puts it.
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 8),
                ],
                Expanded(child: StickyBarTexts(title: title, detail: detail, inline: inlineDetail)),
                if (label != null) ...[
                  const SizedBox(width: 10),
                  Flexible(
                    child: prominent
                        ? StickyBarButton(label: label, icon: actionIcon, onTap: onAction)
                        : StickyBarLink(label: label, onTap: onAction),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
