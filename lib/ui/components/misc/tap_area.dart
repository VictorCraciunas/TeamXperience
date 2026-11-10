import 'package:flutter/material.dart';

/// A control's finger-sized tap area (outdoor use): at least [minSize] across,
/// with what the mockup draws centred in it. Whatever holds it gives back the
/// extra room in its own padding, so the drawing stays where the mockup puts it.
class TapArea extends StatelessWidget {
  const TapArea({super.key, required this.child, required this.onTap, this.label, this.minSize = 48});

  final Widget child;

  /// Silent without it.
  final VoidCallback? onTap;

  /// What a screen reader says; replaces what is inside.
  final String? label;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      enabled: onTap != null,
      label: label,
      onTap: onTap,
      excludeSemantics: label != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Center(widthFactor: 1, heightFactor: 1, child: child),
        ),
      ),
    );
  }
}
