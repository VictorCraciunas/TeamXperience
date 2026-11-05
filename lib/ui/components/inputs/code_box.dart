import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// One character cell of a [CodeBoxesInput], as the mockups' `.in` box with
/// a 20 px content width: 6 px side padding and a 1 px border make it 34
/// wide, 8 px vertical padding and one 20 px mono line at 1.45 make it 47 high.
class CodeBox extends StatelessWidget {
  const CodeBox({
    super.key,
    required this.character,
    required this.active,
    required this.error,
    this.onDark = false,
  });

  final String character;

  /// The box that takes the next character.
  final bool active;
  final bool error;

  /// Drawn on navy, as mockup 05's start code: a 38 x 48 box inside a 2 px
  /// border (the mockup has no box-sizing reset), so 42 x 52.
  final bool onDark;

  static const double width = 34;
  static const double height = 47;
  static const double darkWidth = 42;
  static const double darkHeight = 52;

  @override
  Widget build(BuildContext context) {
    if (onDark) return _dark(context);
    final colors = context.colors;
    final filled = character.isNotEmpty;
    final outline =
        error
            ? colors.danger
            : (filled || active ? colors.tick : colors.border);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        child: SizedBox(
          width: 20,
          child: Text(
            character,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Monospace',
              fontSize: 20,
              height: 1.45,
              color: colors.text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dark(BuildContext context) {
    final colors = context.colors;
    final filled = character.isNotEmpty;
    final outline = error
        ? colors.dangerOnNavy
        : (filled || active ? colors.tickOnNavy : colors.onNavy.withValues(alpha: .3));
    return SizedBox(
      width: darkWidth,
      height: darkHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.onNavy.withValues(alpha: .08),
          border: Border.all(color: outline, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            character,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Monospace',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: colors.onNavy,
            ),
          ),
        ),
      ),
    );
  }
}
