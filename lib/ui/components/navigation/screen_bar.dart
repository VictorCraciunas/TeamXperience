import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// The bar of a short task screen, as in mockup 04: a leading icon (a cross
/// or an arrow), the [title] and an optional [subtitle] under it, on a panel
/// with a 1 px line below. It keeps clear of the status bar. Put it at the
/// top of the page body (not in `Scaffold.appBar`), so it is exactly as tall
/// as its content at every text size.
class ScreenBar extends StatelessWidget {
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

  static const double _maxTextScale = 1.15;

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
