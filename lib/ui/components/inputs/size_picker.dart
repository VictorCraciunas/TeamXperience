import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

/// One box per value from [min] to [max], side by side and equally wide, as
/// in mockup 04: the team size picker. A long range wraps into rows of
/// [_perRow]. Values below [enabledFrom] are shown greyed out and cannot be
/// picked (a team that cannot shrink below its players).
class SizePicker extends StatelessWidget {
  const SizePicker({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.enabledFrom,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;
  final int? enabledFrom;

  static const double _gap = 5;
  static const int _perRow = 8;

  @override
  Widget build(BuildContext context) {
    final count = max < min ? 0 : max - min + 1;
    if (count == 0) return const SizedBox.shrink();
    final perRow = count < _perRow ? count : _perRow;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - _gap * (perRow - 1)) / perRow;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (var n = min; n <= max; n++)
              SizedBox(
                width: width,
                child: _SizeBox(
                  number: n,
                  selected: n == value,
                  onTap: n < (enabledFrom ?? min) ? null : () => onChanged(n),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SizeBox extends StatelessWidget {
  const _SizeBox({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool selected;

  /// Null greys the box out.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onTap == null;
    return Semantics(
      button: true,
      enabled: !disabled,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          key: ValueKey('size-picker-$number'),
          decoration: BoxDecoration(
            color: selected ? colors.navy : (disabled ? colors.inset : colors.panel),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: selected ? colors.navy : colors.border),
          ),
          child: Padding(
            // 7 of CSS padding plus the 1 px border.
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '$number',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                color: selected ? colors.onNavy : (disabled ? colors.muted : colors.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
