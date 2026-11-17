import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/misc/tap_area.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Conversații" with a back arrow and, under it, the event and its number
/// of teams, on a panel with a line below. Sits at the top of the page body,
/// so it grows with the text size instead of clipping.
class TeamChatsHeader extends StatelessWidget {
  const TeamChatsHeader({super.key, required this.subtitle, required this.onBack});

  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              TapArea(
                minSize: 44,
                label: 'Înapoi',
                onTap: onBack,
                child: Icon(TablerIcons.arrow_left, size: 22, color: colors.text),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Conversații',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle(context),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, height: 1.4, color: colors.muted),
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
