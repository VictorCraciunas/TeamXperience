import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

/// A two-or-more-way switch in a pill, as the Listă / Hartă switch of mockup
/// 03: an inset track, the selected segment raised on a panel with accent text.
class PillSwitch extends StatelessWidget {
  const PillSwitch({super.key, required this.options, required this.selected, required this.onSelected});

  /// Icon and label of each segment.
  final List<(IconData, String)> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pill = BorderRadius.circular(AppRadius.pill);
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.inset, border: Border.all(color: colors.insetBorder), borderRadius: pill),
      child: Padding(
        // The mockup's 3, plus the 1 px border drawn inside.
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(i),
                  behavior: HitTestBehavior.opaque,
                  child: DecoratedBox(
                    decoration: i == selected
                        ? BoxDecoration(color: colors.panel, border: Border.all(color: colors.border), borderRadius: pill)
                        : BoxDecoration(border: Border.all(color: colors.inset), borderRadius: pill),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(options[i].$1, size: 16, color: i == selected ? colors.accent : colors.muted),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              options[i].$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                fontWeight: i == selected ? FontWeight.w500 : FontWeight.w400,
                                color: i == selected ? colors.accent : colors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
