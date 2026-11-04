import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A row of round number buttons, one per value from [min] to [max]: the team
/// size picker.
class SizePicker extends StatelessWidget {
  const SizePicker({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;

  static const double _diameter = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var n = min; n <= max; n++)
          Semantics(
            button: true,
            selected: n == value,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(n),
              child: DecoratedBox(
                key: ValueKey('size-picker-$n'),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: n == value ? colors.navy : colors.panel,
                  border: Border.all(color: n == value ? colors.navy : colors.border),
                ),
                child: SizedBox(
                  width: _diameter,
                  height: _diameter,
                  child: Center(
                    child: Text(
                      '$n',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: n == value ? FontWeight.w500 : FontWeight.w400,
                        color: n == value ? colors.onNavy : colors.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
