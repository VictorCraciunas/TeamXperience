import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// Says plainly that no game is open, so Home does not look broken.
class NothingOpenBanner extends StatelessWidget {
  const NothingOpenBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.navActivePill, borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Niciun joc deschis acum',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
            ),
            Text(
              'Jocurile noi apar aici imediat ce se deschid înscrierile.',
              style: TextStyle(fontSize: 13, height: 1.45, color: colors.text),
            ),
          ],
        ),
      ),
    );
  }
}
