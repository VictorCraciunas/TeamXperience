import 'package:flutter/material.dart';

import '../../../utils/calendar_helper.dart';
import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';
import '../buttons/app_button.dart';
import 'period_picker.dart';
import 'period_selection.dart';

/// Opens the period picker as a bottom sheet. Returns the chosen selection
/// (empty means "anytime"), or null when the sheet is dismissed.
Future<PeriodSelection?> showPeriodSheet(
  BuildContext context, {
  PeriodSelection initial = const PeriodSelection(),
  DateTime? now,
}) {
  return showModalBottomSheet<PeriodSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.panel + 2),
      ),
    ),
    builder: (_) => _PeriodSheet(initial: initial, now: now ?? DateTime.now()),
  );
}

class _PeriodSheet extends StatefulWidget {
  const _PeriodSheet({required this.initial, required this.now});

  final PeriodSelection initial;
  final DateTime now;

  @override
  State<_PeriodSheet> createState() => _PeriodSheetState();
}

class _PeriodSheetState extends State<_PeriodSheet> {
  late PeriodSelection _selection = widget.initial;

  bool get _canSave {
    if (_selection.isComplete) return true;
    // Clearing an existing period is a valid save.
    return _selection.isEmpty && !widget.initial.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final presets = periodPresets(widget.now);
    final from = _selection.start;
    final to = _selection.end;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selectează perioada',
            style: TextStyle(
              color: colors.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in presets)
                _PresetChip(
                  label: preset.label,
                  selected: preset.matches(_selection),
                  onTap: () => setState(() => _selection = preset.selection),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (from != null)
            _PeriodPill(
              text:
                  to == null
                      ? CalendarHelper.formatDate(from)
                      : '${CalendarHelper.formatDate(from)} - ${CalendarHelper.formatDate(to)}',
              onClear:
                  () => setState(() => _selection = const PeriodSelection()),
            ),
          PeriodPicker(
            selection: _selection,
            now: widget.now,
            onDayTap:
                (date) => setState(() => _selection = _selection.tap(date)),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Salvează perioada',
            leading: const Icon(Icons.calendar_today_outlined),
            backgroundColor: colors.tick,
            foregroundColor: colors.onTick,
            onPressed:
                _canSave ? () => Navigator.of(context).pop(_selection) : null,
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({required this.text, required this.onClear});

  final String text;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.tick, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onClear,
            tooltip: 'Șterge perioada',
            icon: Icon(Icons.close, size: 20, color: colors.text),
          ),
        ],
      ),
    );
  }
}
