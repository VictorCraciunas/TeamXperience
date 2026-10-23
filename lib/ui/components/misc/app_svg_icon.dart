import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/theme_context.dart';

/// A single-colour SVG icon tinted from the theme (the text colour unless a
/// [color] is given), so the same asset reads well in light and dark mode.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
    this.asset, {
    super.key,
    this.width = 24,
    this.height = 24,
    this.color,
  });

  final String asset;
  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(
        color ?? context.colors.text,
        BlendMode.srcIn,
      ),
    );
  }
}
