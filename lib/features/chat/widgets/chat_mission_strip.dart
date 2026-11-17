import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The organiser's strip on the navy header: one bar per mission (done in
/// teal, the current one amber, the rest faint) and "Misiunea 4 din 6".
class ChatMissionStrip extends StatelessWidget {
  const ChatMissionStrip({super.key, required this.text, required this.total, required this.done, this.current});

  final String text;
  final int total;
  final int done;

  /// The mission being played; null when none is.
  final int? current;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color bar(int i) {
      if (i < done) return colors.tickOnNavy;
      if (i == current) return colors.amber;
      return colors.onNavy.withValues(alpha: .18);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.onNavy.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < total; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(
                    child: DecoratedBox(
                      key: ValueKey('chat-segment-$i'),
                      decoration: BoxDecoration(color: bar(i), borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: const SizedBox(height: 6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          // The text takes what it needs, up to half; the bars the rest.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colors.onNavy.withValues(alpha: .85)),
            ),
          ),
        ],
      )),
    );
  }
}
