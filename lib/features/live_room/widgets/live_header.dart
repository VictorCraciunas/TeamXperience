import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/misc/tap_area.dart';
import 'package:teamxperience/ui/ui.dart';

/// The dark bar on top of the live room and its board (mockup 09): back, a
/// title, a line under it ("● LIVE · 1:17:42 rămase") and round actions.
class LiveHeader extends StatelessWidget {
  const LiveHeader({super.key, required this.title, required this.line, this.live = false, this.actions = const []});

  final String title;
  final String line;

  /// Puts the red "● LIVE" before [line].
  final bool live;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final quiet = TextStyle(fontSize: 11, height: 1.45, color: colors.onNavy.withValues(alpha: .75));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: colors.liveCard,
        child: Padding(
          // The controls' 48 px tap areas take up most of the mockup's padding.
          padding: EdgeInsets.fromLTRB(0, MediaQuery.paddingOf(context).top + 5, 6, 5),
          child: Row(
            children: [
              TapArea(
                onTap: () => Navigator.maybePop(context),
                label: 'Înapoi',
                child: Icon(TablerIcons.arrow_left, size: 18, color: colors.onNavy),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: colors.onNavy),
                    ),
                    Text.rich(
                      TextSpan(
                        style: quiet,
                        children: [
                          if (live) ...[
                            TextSpan(text: '● LIVE', style: TextStyle(color: colors.dangerTextOnNavy)),
                            const TextSpan(text: ' · '),
                          ],
                          TextSpan(text: line),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
