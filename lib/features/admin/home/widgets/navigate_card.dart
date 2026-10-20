import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';

class NavigateCard extends StatelessWidget {
  final String text1;
  final String text2;

  final VoidCallback? onTap;

  const NavigateCard({
    super.key,
    required this.text1,
    required this.text2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: InkSplash.splashFactory,
      onTap: onTap,
      child: Container(
        width: 154,
        height: 115,
        decoration: BoxDecoration(
          color: context.colors.iconButtonBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppSvgIcon(
              'assets/images/add_icon.svg',
              width: 32,
              height: 32,
              color: context.colors.accent,
            ),
            const SizedBox(height: 15),
            Text(
              text1,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.text,
              ),
            ),
            Text(
              text2,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
