import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A labelled row of colour swatches (hex strings like `#33FF66`). Tapping a
/// swatch selects it; tapping the selected one again clears the choice.
class ColorSwatchRow extends StatelessWidget {
  const ColorSwatchRow({
    super.key,
    required this.label,
    required this.swatches,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<String> swatches;
  final String? selected;

  /// The new choice, or null when the selected swatch was tapped again.
  final ValueChanged<String?> onChanged;

  static Color? _parse(String hex) {
    final clean = hex.replaceFirst('#', '');
    final value = int.tryParse(
      clean.length == 6 ? 'FF$clean' : clean,
      radix: 16,
    );
    return value == null ? null : Color(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final current = selected;
    final shown = [
      ...swatches,
      if (current != null && !swatches.contains(current)) current,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final hex in shown)
              _Swatch(
                key: ValueKey('swatch-$hex'),
                color: _parse(hex) ?? Colors.transparent,
                selected: hex == current,
                onTap: () => onChanged(hex == current ? null : hex),
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Black or white check, whichever reads on the swatch.
    final checkColor =
        color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? colors.tick : colors.border,
                width: selected ? 3 : 1,
              ),
            ),
            child:
                selected
                    ? Icon(Icons.check, size: 18, color: checkColor)
                    : null,
          ),
        ),
      ),
    );
  }
}
