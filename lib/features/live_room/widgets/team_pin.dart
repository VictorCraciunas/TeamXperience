import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/contrast.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/live_map_points.dart';

/// A team on the map (mockup 09 `.pin`): its initial in a circle coloured by
/// how the team stands, with a white ring; a [selected] one (the team the big
/// map was opened on) gets a thick ring in the text colour.
class TeamPin extends StatelessWidget {
  const TeamPin({super.key, required this.initial, required this.tone, this.size = 24, this.selected = false, this.onTap});

  final String initial;
  final PinTone tone;
  final bool selected;

  /// Across, ring included.
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = switch (tone) {
      PinTone.playing => colors.navy,
      PinTone.stuck => colors.amber,
      PinTone.finished => colors.accent,
      PinTone.silent => colors.muted,
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? colors.text : colors.panel, width: selected ? 3 : 2),
        ),
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: Text(
              initial,
              maxLines: 1,
              textScaler: TextScaler.noScaling,
              style: TextStyle(fontSize: size * 11 / 24, fontWeight: FontWeight.w500, color: readableOn([fill])),
            ),
          ),
        ),
      ),
    );
  }
}
