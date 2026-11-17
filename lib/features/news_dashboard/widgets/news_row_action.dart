import 'package:flutter/material.dart';

/// A 44 px round button on an organiser's news row (edit, delete): a tinted
/// circle with an 18 px icon, and [tooltip] as its screen-reader label.
class NewsRowAction extends StatelessWidget {
  const NewsRowAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        child: Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 18, color: foreground)),
          ),
        ),
      ),
    );
  }
}
