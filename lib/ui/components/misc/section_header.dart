import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A heading over a group of cards: a title and, at the right, a muted count
/// or an accent link with a 44 px tap area, which the space above and below
/// the title is part of.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing, this.trailingChild, this.link, this.onLink, this.top = 14});

  final String title;

  /// A count or note at the right, muted.
  final String? trailing;

  /// Anything else at the right (a count in a pill), instead of [trailing].
  final Widget? trailingChild;

  /// A link at the right ("Vezi toate"), used instead of [trailing].
  final String? link;
  final VoidCallback? onLink;

  /// The space above: 14 on the Evenimente tab, 16 on Home (mockup 02).
  final double top;

  static const double _tap = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final note = trailing;
    final action = link;
    final child = trailingChild;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, top > 8 ? top - 8 : 0, 14, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _tap),
        child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
            ),
          ),
          if (child != null)
            child
          else if (action != null)
            GestureDetector(
              onTap: onLink,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: _tap,
                child: Center(
                  child: Text(
                action,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.45, color: colors.accent),
                  ),
                ),
              ),
            )
          else if (note != null)
            Text(note, style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted)),
        ],
        ),
      ),
    );
  }
}
