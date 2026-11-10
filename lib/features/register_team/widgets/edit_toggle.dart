import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// "Editează" / "Anulează" in the accent colour, as on the team page, with a
/// 44 px tap area. [onTap] null greys it out.
class EditToggle extends StatelessWidget {
  const EditToggle({super.key, required this.editing, required this.onTap});

  final bool editing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            widthFactor: 1,
            child: Text(
              editing ? 'Anulează' : 'Editează',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: onTap == null ? colors.muted : colors.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
