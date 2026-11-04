import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// One character cell of a [CodeBoxesInput].
class CodeBox extends StatelessWidget {
  const CodeBox({super.key, required this.character, required this.active, required this.error});

  final String character;

  /// The box that takes the next character.
  final bool active;
  final bool error;

  static const double width = 38;
  static const double height = 46;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final outline = error ? colors.danger : (active ? colors.tick : colors.border);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: outline, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Text(
            character,
            style: TextStyle(
              fontFamily: 'Monospace',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.text,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
