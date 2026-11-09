import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A 32 px round button over the hero (back, share).
class HeroRoundButton extends StatelessWidget {
  const HeroRoundButton({super.key, required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: colors.heroButton,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 20, color: colors.text)),
        ),
      ),
    );
  }
}
