import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A wide pill button with the tick-coloured ring used across the feed
/// controls: panel fill, icon and label. For "create" actions in a header.
class TickOutlineButton extends StatelessWidget {
  const TickOutlineButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: DecoratedBox(
          key: const ValueKey('tick-outline-button-box'),
          decoration: BoxDecoration(
            color: colors.panel,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: colors.tick, width: 1.5),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: colors.text),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
