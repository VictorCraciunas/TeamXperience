import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// The top of the Știri list: a back arrow when the page was pushed (none as
/// an organiser's tab), the title with an optional line under it, and an
/// optional widget at the right. It keeps clear of the status bar.
class NewsHeader extends StatelessWidget {
  const NewsHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sub = subtitle;
    final right = trailing;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(canPop ? 4 : AppSpacing.page, 6, 12, 6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                if (canPop) ...[
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Înapoi',
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    icon: Icon(TablerIcons.arrow_left, size: 22, color: colors.text),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colors.text),
                      ),
                      if (sub != null)
                        Text(
                          sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: colors.muted),
                        ),
                    ],
                  ),
                ),
                if (right != null) ...[const SizedBox(width: 8), right],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
