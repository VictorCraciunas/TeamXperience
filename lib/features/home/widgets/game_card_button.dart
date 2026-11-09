import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The bright button on a Home game card ("Continuă jocul"): tick fill,
/// radius 12, padding 10, centred w500 text.
class GameCardButton extends StatelessWidget {
  const GameCardButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.tickOnNavy,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: colors.onTick),
          ),
        ),
      ),
    );
  }
}
