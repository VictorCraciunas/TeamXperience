import 'package:flutter/material.dart';

/// An outlined action on the board's bar and the team sheet: "Anunț",
/// "Oprește", "Sună căpitanul". It stays silent without [onTap].
class BoardActionButton extends StatelessWidget {
  const BoardActionButton({super.key, required this.label, required this.icon, required this.colour, this.onTap});

  final String label;
  final IconData icon;
  final Color colour;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? .45 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colour, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14, color: colour),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: colour),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
