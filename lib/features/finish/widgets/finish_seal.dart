import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The seal at the top of the finish screen (mockup 08): 74 across inside a
/// 3 px second-accent ring (80 in all), the surface colour and a 34 px map.
class FinishSeal extends StatelessWidget {
  const FinishSeal({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    return DecoratedBox(
      key: const ValueKey('finish-seal'),
      decoration: BoxDecoration(
        color: palette.surface,
        shape: BoxShape.circle,
        border: Border.all(color: palette.secondaryAccent, width: 3),
      ),
      child: SizedBox.square(
        dimension: 80,
        child: Center(child: Icon(TablerIcons.map_2, size: 34, color: palette.accent)),
      ),
    );
  }
}
