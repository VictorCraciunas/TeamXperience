import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The end of the route when no locked missions are left to carry the flag:
/// a 32 px circle with a 2 px accent ring and a 16 px accent flag.
class TrailFinishStop extends StatelessWidget {
  const TrailFinishStop({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    return DecoratedBox(
      key: const ValueKey('trail-finish'),
      decoration: BoxDecoration(
        color: palette.surface,
        shape: BoxShape.circle,
        border: Border.all(color: palette.accent, width: 2),
      ),
      child: SizedBox.square(
        dimension: 32,
        child: Center(child: Icon(TablerIcons.flag, size: 16, color: palette.accent)),
      ),
    );
  }
}
