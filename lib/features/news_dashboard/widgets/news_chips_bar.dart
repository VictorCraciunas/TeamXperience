import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';

/// One chip of the Știri list.
typedef NewsChip = ({String label, bool selected, VoidCallback onTap});

/// The chips under the header, in a row that scrolls sideways.
class NewsChipsBar extends StatelessWidget {
  const NewsChipsBar({super.key, required this.chips});

  final List<NewsChip> chips;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SingleChildScrollView(
        key: const ValueKey('news-chips'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final (i, chip) in chips.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              AppChip(
                label: chip.label,
                style: chip.selected ? AppChipStyle.selected : AppChipStyle.plain,
                onTap: chip.onTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
