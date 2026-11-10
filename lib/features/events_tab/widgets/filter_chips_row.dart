import 'package:flutter/material.dart';
import 'package:teamxperience/features/events_tab/logic/event_filters.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';

/// The chips under the Evenimente header: "Toate" and the filters, in a row
/// that scrolls sideways.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key, required this.query, required this.onToggle, required this.onAll});

  final EventQuery query;
  final void Function(EventFilter) onToggle;
  final VoidCallback onAll;

  static const _labels = {
    EventFilter.thisMonth: ('Luna asta', null),
    EventFilter.easy: ('Ușor', '●'),
    EventFilter.medium: ('Mediu', '●●'),
    EventFilter.hard: ('Greu', '●●●'),
    EventFilter.under2h: ('Sub 2 h', null),
  };

  @override
  Widget build(BuildContext context) {
    AppChipStyle style(bool on) => on ? AppChipStyle.selected : AppChipStyle.plain;
    return SingleChildScrollView(
      key: const ValueKey('filter-chips'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          AppChip(label: 'Toate', style: style(query.isAll), onTap: onAll),
          for (final f in EventFilter.values) ...[
            const SizedBox(width: 6),
            AppChip(
              label: _labels[f]?.$1 ?? '',
              lead: _labels[f]?.$2,
              style: style(query.filters.contains(f)),
              onTap: () => onToggle(f),
            ),
          ],
        ],
      ),
    );
  }
}
