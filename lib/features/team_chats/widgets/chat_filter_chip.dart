import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// One of the list's filters, "Toate · 12" or "Necitite · 3": navy when
/// chosen, an outlined pill otherwise, with an optional red dot before the
/// label. The pill is 36 tall; the tap area 44.
class ChatFilterChip extends StatelessWidget {
  const ChatFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dot = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = selected ? colors.navy : colors.panel;
    final outline = selected ? colors.navy : colors.border;
    final textColor = selected ? colors.onNavy : colors.text;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Align(
            widthFactor: 1,
            heightFactor: 1,
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: fill,
                border: Border.all(color: outline),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dot) ...[
                    Container(
                      key: const ValueKey('chat-filter-dot'),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: colors.live, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.45, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
