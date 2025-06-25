import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';

class StiriAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarText;
  final String? iconString;
  final VoidCallback? onIconTap;

  const StiriAppBar({
    super.key,
    required this.appBarText,
    this.iconString,
    this.onIconTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      backgroundColor: MyColors.backgroundColor,
      title: Text(
        appBarText,
        style: const TextStyle(
          fontSize: 24,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: MyColors.blackColor,
        ),
      ),
      centerTitle: true,
      actions: [
        if (iconString != null)
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: onIconTap,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: MyColors.transparentLightBlue,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconString!,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}