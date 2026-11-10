import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

import 'package:teamxperience/ui/components/inputs/register_input.dart';

/// The team name: a teal paw badge, the input (teal with a check once the
/// name is free) and the status line under it, as in mockup 04.
class TeamNameField extends StatelessWidget {
  const TeamNameField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.status,
    required this.statusText,
    this.readOnly = false,
    this.dimmed = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FieldStatus status;
  final String statusText;
  final bool readOnly;

  /// Greyed out: the name is filled in and cannot be changed now.
  final bool dimmed;

  static const double _badge = 42;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ok = status == FieldStatus.ok;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              key: const ValueKey('team-name-badge'),
              decoration: BoxDecoration(
                color: colors.tick,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: SizedBox(
                width: _badge,
                height: _badge,
                child: Icon(TablerIcons.paw, size: 22, color: colors.onTick),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RegisterInput(
                controller: controller,
                onChanged: onChanged,
                readOnly: readOnly || dimmed,
                dimmed: dimmed,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                borderColor: ok ? colors.tick : null,
                // As tall as the badge: its 42 less one text line of 14 x 1.45.
                verticalPadding: (_badge - 14 * 1.45) / 2,
                trailing:
                    ok
                        ? Icon(
                          TablerIcons.circle_check,
                          size: 16,
                          color: colors.success,
                        )
                        : null,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: FieldStatusLine(text: statusText, status: status),
        ),
      ],
    );
  }
}
