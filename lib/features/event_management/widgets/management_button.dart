import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/widgets/my_button.dart';

class ManagementButton extends StatelessWidget {
  final String text;
  final String icon;
  final bool enabled;
  final VoidCallback onTap;

  const ManagementButton({
    super.key,
    required this.text,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: MyButton(
        buttonText: text,
        textColor: MyColors.blackColor,
        buttonOnTap: enabled ? onTap : () {},
        withBorder: false,
        buttonColor: MyColors.transparentLightBlue,
        leading: SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
        ),
        buttonTextSize: 15,
      ),
    );
  }
}
