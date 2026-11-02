import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';

/// The round back button at the top left of the mission list.
class GameBackButton extends StatelessWidget {
  const GameBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0x90FFFFFF),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const AppSvgIcon('assets/images/back_icon.svg', width: 24, height: 24),
          ),
        ),
      ),
    );
  }
}
