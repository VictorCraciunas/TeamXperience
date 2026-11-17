import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/misc/tap_area.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Echipe înscrise" with a 44 px back button and the event under it, on a
/// panel with a line below. It keeps clear of the status bar.
class RegisteredTeamsHeader extends StatelessWidget {
  const RegisteredTeamsHeader({super.key, required this.onBack, this.subtitle});

  final VoidCallback onBack;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sub = subtitle;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              TapArea(
                minSize: 44,
                label: 'Înapoi',
                onTap: onBack,
                child: Icon(TablerIcons.arrow_left, size: 22, color: colors.text),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Echipe înscrise',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle(context),
                    ),
                    if (sub != null)
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: colors.muted),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
