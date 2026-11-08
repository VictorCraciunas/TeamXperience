import 'package:flutter/material.dart';

/// A 30 px round button on a queue card, in a 36 px tap area. Faded and silent
/// without [onTap].
class QueueRoundButton extends StatelessWidget {
  const QueueRoundButton({
    super.key,
    required this.icon,
    required this.label,
    this.fill,
    required this.ink,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? fill;
  final Color ink;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? .45 : 1,
          child: SizedBox.square(
            dimension: 36,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
                child: SizedBox.square(dimension: 30, child: Icon(icon, size: 15, color: ink)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
