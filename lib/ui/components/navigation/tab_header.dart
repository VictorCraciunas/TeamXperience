import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// The top of a tab, as in mockup 03 (Evenimente, Echipe): a 17 px title on
/// a panel with a 1 px line below, an optional widget at the right and an
/// optional row 10 px under the title. It keeps clear of the status bar.
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, this.trailing, this.bottom});

  final String title;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final right = trailing;
    final below = bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          // The mockup's 12, plus the 1 px border drawn inside at the bottom.
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
                    ),
                  ),
                  if (right != null) right,
                ],
              ),
              if (below != null) ...[const SizedBox(height: 10), below],
            ],
          ),
        ),
      ),
    );
  }
}
