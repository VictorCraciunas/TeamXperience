import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/brand_title.dart';
import 'package:teamxperience/ui/ui.dart';

/// The brand on the signed-out landing page, drawn as text so it stays sharp:
/// "TeamXperience" large, and the line the old logo carried under it. Narrow
/// screens and large text scale it down instead of cutting it.
class SplashBrand extends StatelessWidget {
  const SplashBrand({super.key});

  static const double titleSize = 40;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandTitle(fontSize: titleSize),
            Text(
              'teambuilding redefinit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: context.colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
