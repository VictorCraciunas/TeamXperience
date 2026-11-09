import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// A round pin on the Evenimente map: navy, or teal for an event the player
/// is in. With several events on one spot it shows how many.
class EventMapPin extends StatelessWidget {
  const EventMapPin({super.key, required this.registered, required this.onTap, this.count = 1});

  final bool registered;
  final VoidCallback onTap;
  final int count;

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
        child: count > 1
            ? Center(
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: registered ? colors.onTick : colors.onNavy),
                ),
              )
            : Icon(TablerIcons.map_pin, size: 16, color: registered ? colors.onTick : colors.onNavy),
      ),
    );
  }
}
