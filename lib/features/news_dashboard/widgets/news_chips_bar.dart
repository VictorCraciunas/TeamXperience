import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';

/// One chip of the Știri list.
typedef NewsChip = ({String label, bool selected, VoidCallback onTap});

/// The chips under the header, in a row that scrolls sideways, with
/// [trailing] buttons (search, filter) fixed at its right end.
class NewsChipsBar extends StatelessWidget {
  const NewsChipsBar({super.key, required this.chips, this.trailing = const []});

  final List<NewsChip> chips;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8, right: trailing.isEmpty ? 0 : 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('news-chips'),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16, right: trailing.isEmpty ? 16 : 8),
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
          ),
          for (final (i, button) in trailing.indexed) ...[
            if (i > 0) const SizedBox(width: 6),
            button,
          ],
        ],
      ),
    );
  }
}
