import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A 44 px round button next to the chips (search, filter, period). [active]
/// fills it with the accent tint while its search or filter is on.
class NewsToolButton extends StatelessWidget {
  const NewsToolButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? colors.navActivePill : colors.iconButtonBg,
        shape: CircleBorder(side: active ? BorderSide(color: colors.tick) : BorderSide.none),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 20, color: active ? colors.accent : colors.text),
          ),
        ),
      ),
    );
  }
}
