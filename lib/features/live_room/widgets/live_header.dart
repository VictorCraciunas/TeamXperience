import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
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
          padding: EdgeInsets.fromLTRB(14, MediaQuery.paddingOf(context).top + 12, 14, 12),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Înapoi',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.maybePop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Icon(TablerIcons.arrow_left, size: 18, color: colors.onNavy),
                  ),
                ),
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
              for (final action in actions) ...[const SizedBox(width: 8), action],
            ],
          ),
        ),
      ),
    );
  }
}
