import 'package:flutter/material.dart';

import '../../../utils/calendar_helper.dart';
import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';
import '../buttons/app_button.dart';
import 'period_selection.dart';
import 'period_sheet.dart';

/// One choice inside a [FilterGroup].
class FilterOption {
  const FilterOption(this.id, this.label);

  final String id;
  final String label;
}

/// A set of mutually exclusive choices (plus an implicit "Toate").
class FilterGroup {
  const FilterGroup({
    required this.id,
    required this.title,
    required this.options,
    this.onAdd,
    this.addTooltip = 'Adaugă',
    this.onOptionLongPress,
  });

  final String id;
  final String title;
  final List<FilterOption> options;

  /// When set, the group ends with a "+" chip. It should ask for the new
  /// option (for example with a dialog), save it, and return it, or null to
  /// cancel. The returned option is added to the group and selected.
  final Future<FilterOption?> Function()? onAdd;
  final String addTooltip;

  /// When set, long-pressing an option calls it. It should confirm and delete
  /// the option and return true if it was deleted; the option then disappears
  /// from the sheet.
  final Future<bool> Function(FilterOption option)? onOptionLongPress;
}

/// What the user chose: a period and, per group id, the chosen option id. A
/// group missing from [selected] means "Toate".
class FilterSheetResult {
  const FilterSheetResult({required this.period, required this.selected});

  final PeriodSelection period;
  final Map<String, String> selected;
}

/// The admin filter sheet: a period plus any number of option groups, applied
/// together. Returns null when dismissed.
Future<FilterSheetResult?> showFilterSheet(
  BuildContext context, {
  required List<FilterGroup> groups,
  PeriodSelection period = const PeriodSelection(),
  Map<String, String> selected = const {},
  String title = 'Filtre',
  DateTime? now,
}) {
  return showModalBottomSheet<FilterSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.panel + 2),
      ),
    ),
    builder:
        (_) => _FilterSheet(
          title: title,
          groups: groups,
          initialPeriod: period,
          initialSelected: selected,
          now: now ?? DateTime.now(),
        ),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.title,
    required this.groups,
    required this.initialPeriod,
    required this.initialSelected,
    required this.now,
  });

  final String title;
  final List<FilterGroup> groups;
  final PeriodSelection initialPeriod;
  final Map<String, String> initialSelected;
  final DateTime now;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late PeriodSelection _period = widget.initialPeriod;
  late final Map<String, String> _selected = Map.of(widget.initialSelected);

  /// Options added from the sheet, per group id.
  final Map<String, List<FilterOption>> _added = {};

  /// Ids of options deleted from the sheet, per group id.
  final Map<String, Set<String>> _removed = {};

  List<FilterOption> _optionsOf(FilterGroup group) {
    final removed = _removed[group.id] ?? const <String>{};
    return [
      ...group.options,
      ...?_added[group.id],
    ].where((o) => !removed.contains(o.id)).toList();
  }

  Future<void> _longPress(FilterGroup group, FilterOption option) async {
    final handler = group.onOptionLongPress;
    if (handler == null) return;
    final deleted = await handler(option);
    if (!deleted || !mounted) return;
    setState(() {
      _removed.putIfAbsent(group.id, () => {}).add(option.id);
      if (_selected[group.id] == option.id) _selected.remove(group.id);
    });
  }

  Future<void> _addTo(FilterGroup group) async {
    final add = group.onAdd;
    if (add == null) return;
    final option = await add();
    if (option == null || !mounted) return;
    setState(() {
      _added.putIfAbsent(group.id, () => []).add(option);
      _selected[group.id] = option.id;
    });
  }

  Future<void> _pickCustomPeriod() async {
    final picked = await showPeriodSheet(
      context,
      initial: _period,
      now: widget.now,
    );
    if (picked != null) setState(() => _period = picked);
  }

  void _choose(String groupId, String? optionId) {
    setState(() {
      if (optionId == null) {
        _selected.remove(groupId);
      } else {
        _selected[groupId] = optionId;
      }
    });
  }

  void _reset() {
    setState(() {
      _period = const PeriodSelection();
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final presets = periodPresets(widget.now);
    final matchedPreset = presets.where((p) => p.matches(_period)).isNotEmpty;
    final from = _period.start;
    final to = _period.end;
    // Once a custom range is chosen, its chip shows the dates.
    final customRange =
        (!matchedPreset && from != null && to != null)
            ? '${CalendarHelper.formatDate(from)} - ${CalendarHelper.formatDate(to)}'
            : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _reset,
                child: Text(
                  'Șterge filtrele',
                  style: TextStyle(
                    color: colors.text,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const _SectionLabel('Perioadă'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in presets)
                _Choice(
                  label: preset.label,
                  selected: preset.matches(_period),
                  onTap: () => setState(() => _period = preset.selection),
                ),
              _Choice(
                label: customRange ?? 'Dată personalizată',
                selected: customRange != null,
                onTap: _pickCustomPeriod,
              ),
            ],
          ),
          for (final group in widget.groups) ...[
            _SectionLabel(group.title),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Choice(
                  label: 'Toate',
                  selected: !_selected.containsKey(group.id),
                  onTap: () => _choose(group.id, null),
                ),
                for (final option in _optionsOf(group))
                  _Choice(
                    label: option.label,
                    selected: _selected[group.id] == option.id,
                    onTap: () => _choose(group.id, option.id),
                    onLongPress:
                        group.onOptionLongPress == null
                            ? null
                            : () => _longPress(group, option),
                  ),
                if (group.onAdd != null)
                  _AddChip(
                    key: ValueKey('filter-add-chip-${group.id}'),
                    tooltip: group.addTooltip,
                    onTap: () => _addTo(group),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Anulează',
                  variant: AppButtonVariant.secondary,
                  foregroundColor: colors.text,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Aplică',
                  backgroundColor: colors.tick,
                  foregroundColor: colors.onTick,
                  onPressed:
                      () => Navigator.of(context).pop(
                        FilterSheetResult(
                          period: _period,
                          selected: Map.of(_selected),
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: context.colors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// The "+" chip at the end of a group that can add options.
class _AddChip extends StatelessWidget {
  const _AddChip({super.key, required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.panel,
        shape: StadiumBorder(side: BorderSide(color: colors.tick, width: 1.5)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 40,
            child: Icon(Icons.add, size: 20, color: colors.text),
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: selected ? colors.tick : colors.panel,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? colors.tick : colors.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? colors.onTick : colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
