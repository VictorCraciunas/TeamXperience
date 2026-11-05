import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// A 32 px round pin on the Evenimente map: navy, or teal for an event the
/// player is in.
class EventMapPin extends StatelessWidget {
  const EventMapPin({super.key, required this.registered, required this.onTap});

  final bool registered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: registered ? colors.tick : colors.navy,
          shape: BoxShape.circle,
          border: Border.all(color: colors.panel, width: 2),
        ),
        child: Icon(TablerIcons.map_pin, size: 16, color: registered ? colors.onTick : colors.onNavy),
      ),
    );
  }
}
