import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarText;

  const MyAppBar({
    super.key,
    required this.appBarText,
  });

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
          color: Color(0xFF0C092A),
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}