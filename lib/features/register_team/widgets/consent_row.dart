import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// A tick box and its label, as in mockup 04. Tapping anywhere on the row
/// toggles it; with [onChanged] null it cannot be changed.
class ConsentRow extends StatelessWidget {
  const ConsentRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final change = onChanged;
    final toggle = change == null ? null : () => change(!value);

    return Semantics(
      checked: value,
      enabled: change != null,
      label: label,
      excludeSemantics: true,
      onTap: toggle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: toggle,
        child: Row(
          children: [
            DecoratedBox(
              key: const ValueKey('consent-box'),
              decoration: BoxDecoration(
                color: value ? colors.accent : colors.panel,
                borderRadius: BorderRadius.circular(5),
                border:
                    value ? null : Border.all(color: colors.border, width: 1.5),
              ),
              child: SizedBox(
                width: 18,
                height: 18,
                child:
                    value
                        ? Icon(
                          TablerIcons.check,
                          size: 12,
                          color: colors.onNavy,
                        )
                        : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: AppTextStyles.pageBody(context)),
            ),
          ],
        ),
      ),
    );
  }
}
