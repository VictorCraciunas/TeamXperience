import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/theme_context.dart';

enum FieldStatus { neutral, checking, ok, problem }

/// The small line under a field: a hint, a check in progress, "Numele e
/// liber" or what is wrong.
class FieldStatusLine extends StatelessWidget {
  const FieldStatusLine({super.key, required this.text, required this.status});

  final String text;
  final FieldStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = switch (status) {
      FieldStatus.ok => colors.success,
      FieldStatus.problem => colors.danger,
      FieldStatus.neutral || FieldStatus.checking => colors.muted,
    };
    final Widget? leading = switch (status) {
      FieldStatus.ok => Icon(TablerIcons.circle_check, size: 13, color: color),
      FieldStatus.problem => Icon(TablerIcons.alert_circle, size: 13, color: color),
      FieldStatus.checking => SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
      ),
      FieldStatus.neutral => null,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          // A 13 px icon beside a 16 px line: centred on the first line.
          Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: SizedBox(width: 13, child: Center(child: leading)),
          ),
          const SizedBox(width: 4),
        ],
        Expanded(child: Text(text, style: TextStyle(fontSize: 11, color: color, height: 1.45))),
      ],
    );
  }
}
