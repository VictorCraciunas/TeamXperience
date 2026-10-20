import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

/// A row of pill-shaped choices with one selected, for filtering a feed.
class ChoiceChipsRow extends StatelessWidget {
  const ChoiceChipsRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Material(
              color: i == selectedIndex ? colors.accent : colors.panel,
              shape: StadiumBorder(
                side: BorderSide(color: i == selectedIndex ? colors.accent : colors.border),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onSelected(i),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          color: i == selectedIndex ? Colors.white : colors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
