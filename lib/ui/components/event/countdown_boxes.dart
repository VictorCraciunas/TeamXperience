import 'package:flutter/material.dart';

import 'countdown_box.dart';

/// Days, hours and minutes to an event in three boxes on a navy card, as in
/// mockup 02: a 17 px value over an 11 px label.
class CountdownBoxes extends StatelessWidget {
  const CountdownBoxes({super.key, required this.left});

  final Duration left;

  @override
  Widget build(BuildContext context) {
    final total = left.isNegative ? Duration.zero : left;
    final parts = [
      (total.inDays, 'zile'),
      (total.inHours.remainder(24), 'ore'),
      (total.inMinutes.remainder(60), 'min'),
    ];
    return Row(
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: CountdownBox(value: parts[i].$1, label: parts[i].$2)),
        ],
      ],
    );
  }
}
