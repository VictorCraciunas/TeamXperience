import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// The bar of a short task screen, as in mockup 04: a leading icon (a cross
/// or an arrow), the [title] and an optional [subtitle] under it, on a panel
/// with a 1 px line below. It keeps clear of the status bar.
class ScreenBar extends StatelessWidget implements PreferredSizeWidget {
  const ScreenBar({
    super.key,
    required this.leadingIcon,
    required this.onLeading,
    required this.title,
    this.subtitle,
  });

  final IconData leadingIcon;
  final VoidCallback onLeading;
  final String title;
  final String? subtitle;

  static const double _lineHeight = 1.45;
  static const double _maxTextScale = 1.15;

  /// 12 px of padding above, 13 below (12 plus the border), the title line,
  /// and the subtitle line when there is one. The lines are sized for the
  /// largest text the bar allows, [_maxTextScale].
  @override
  Size get preferredSize {
    final hasSubtitle = subtitle != null;
    final text =
        (12 * _lineHeight + (hasSubtitle ? 11 * _lineHeight : 0)) *
        _maxTextScale;
    final content = text > 18 ? text : 18.0;
    return Size.fromHeight(12 + content + 13);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sub = subtitle;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: _maxTextScale,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLeading,
                  child: Icon(leadingIcon, size: 18, color: colors.text),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle(context),
                      ),
                      if (sub != null)
                        Text(
                          sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.smallMuted(context),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
