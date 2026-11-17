import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/tap_area.dart';

/// A 44 px round button of the chat's header: [icon] in [colour] on a
/// [fill] (none for the back arrow). Faded and silent without [onTap].
class ChatHeaderButton extends StatelessWidget {
  const ChatHeaderButton({
    super.key,
    required this.icon,
    required this.label,
    required this.colour,
    required this.onTap,
    this.fill,
    this.iconSize = 20,
  });

  final IconData icon;

  /// What a screen reader says ("Sună căpitanul").
  final String label;
  final Color colour;
  final Color? fill;
  final VoidCallback? onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return TapArea(
      minSize: 44,
      label: label,
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : .4,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
          child: Icon(icon, size: iconSize, color: colour),
        ),
      ),
    );
  }
}
