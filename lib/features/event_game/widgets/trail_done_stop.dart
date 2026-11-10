import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// A solved mission on the trail (mockup 06): a 32 px accent circle with a
/// 16 px check in the page colour, the label 8 px beside it (on the left for
/// stops on the right-hand side).
class TrailDoneStop extends StatelessWidget {
  const TrailDoneStop({super.key, required this.number, required this.label, this.labelOnLeft = false});

  final int number;
  final String label;
  final bool labelOnLeft;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final circle = DecoratedBox(
      key: ValueKey('trail-done-$number'),
      decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: 32,
        child: Center(child: Icon(TablerIcons.check, size: 16, color: palette.background)),
      ),
    );
    final text = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: labelOnLeft ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 13, height: 1.45, color: palette.ink),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: labelOnLeft ? [text, const SizedBox(width: 8), circle] : [circle, const SizedBox(width: 8), text],
    );
  }
}
