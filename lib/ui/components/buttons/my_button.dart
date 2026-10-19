import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';

import 'app_button.dart';

/// Legacy button kept so existing screens keep compiling. It renders an
/// [AppButton]: gradient and themed-colour buttons become the primary variant,
/// bordered buttons the secondary one, and any other fill colour (for example a
/// brand colour) is passed through as an override. Radius, font weight and font
/// size are accepted but ignored. New code should use [AppButton] directly.
class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.buttonText,
    required this.textColor,
    required this.buttonOnTap,
    required this.withBorder,
    this.buttonColor,
    this.gradient,
    this.leading,
    this.fontWeight = FontWeight.w500,
    this.radius = 50,
    this.buttonWidth = double.infinity,
    this.buttonTextSize = 16,
  });

  final String buttonText;
  final Color? buttonColor;
  final Color textColor;
  final LinearGradient? gradient;
  final VoidCallback buttonOnTap;
  final Widget? leading;
  final bool withBorder;
  final FontWeight fontWeight;
  final double radius;
  final double buttonWidth;
  final double buttonTextSize;

  static const _themedFills = [
    MyColors.lightBlue,
    MyColors.yellow,
    MyColors.transparentLightBlue,
  ];

  @override
  Widget build(BuildContext context) {
    final fill = buttonColor;
    final isBrandOverride = fill != null && !_themedFills.contains(fill);
    final variant = (withBorder && gradient == null && fill == null)
        ? AppButtonVariant.secondary
        : AppButtonVariant.primary;

    final button = AppButton(
      label: buttonText,
      onPressed: buttonOnTap,
      variant: variant,
      leading: leading,
      backgroundColor: isBrandOverride ? fill : null,
      foregroundColor: isBrandOverride ? textColor : null,
    );

    if (buttonWidth.isFinite) {
      return SizedBox(width: buttonWidth, child: button);
    }
    return button;
  }
}
