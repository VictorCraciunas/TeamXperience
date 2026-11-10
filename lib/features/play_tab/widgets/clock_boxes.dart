import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import 'rolling_number.dart';

/// The countdown boxes on a ticket's top: a rolling mono number over its
/// unit, in equal boxes (mockup 10).
class ClockBoxes extends StatelessWidget {
  const ClockBoxes({super.key, required this.parts});

  final List<(String value, String label)> parts;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(color: colors.onNavyFaint, borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: RollingNumber(
                        value: parts[i].$1,
                        style: TextStyle(
                          fontFamily: 'Monospace',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: colors.onNavy,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        parts[i].$2,
                        style: TextStyle(fontSize: 12, height: 1.45, color: colors.onNavy.withValues(alpha: .75)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
