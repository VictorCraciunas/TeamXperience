import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// "TeamXperience" drawn as text, as on teamxperience.ro: Poppins bold, the X
/// in the brand yellow. Text keeps it sharp at any size, where the old
/// logo.png was blurred. Acasă's header uses the default 20; the signed-out
/// landing page draws it larger.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.fontSize = 20});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, height: 1.45, color: colors.text),
        children: [
          const TextSpan(text: 'Team'),
          TextSpan(text: 'X', style: TextStyle(color: colors.brandX)),
          const TextSpan(text: 'perience'),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
