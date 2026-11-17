import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Caută echipa sau jucătorul": a 44 px field with a search glass.
class TeamSearchField extends StatelessWidget {
  const TeamSearchField({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.panel,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(TablerIcons.search, size: 18, color: colors.muted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(fontSize: 14, color: colors.text),
                  cursorColor: colors.accent,
                  decoration: InputDecoration(
                    hintText: 'Caută echipa sau jucătorul',
                    hintStyle: TextStyle(fontSize: 14, color: colors.muted),
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
