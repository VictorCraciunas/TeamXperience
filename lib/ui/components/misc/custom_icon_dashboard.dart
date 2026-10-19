import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';


class CustomIconDashBoard extends StatelessWidget {
  const CustomIconDashBoard({
    super.key,
    required this.activeFilter,
    required this.onTap,
    required this.iconString
  });

  final bool activeFilter;
  final Function onTap;
  final iconString;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: InkSplash.splashFactory,
      onTap: () => onTap(),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: activeFilter
              ? context.colors.accent
              : context.colors.iconButtonBg,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconString,
            width: 24,
            height: 24,
            colorFilter: activeFilter
                ? const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            )
                : null,
          ),
        ),
      ),
    );
  }
}