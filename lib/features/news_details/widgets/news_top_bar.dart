import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';

import 'news_round_button.dart';

/// Back and share over the top of the news picture.
class NewsTopBar extends StatelessWidget {
  const NewsTopBar({super.key, required this.onBack, required this.onShare});

  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NewsRoundButton(
              label: 'Înapoi',
              icon: const AppSvgIcon('assets/images/back_icon.svg'),
              onTap: onBack,
            ),
            NewsRoundButton(
              label: 'Distribuie',
              icon: const AppSvgIcon('assets/images/download.svg'),
              onTap: onShare,
            ),
          ],
        ),
      ),
    );
  }
}
