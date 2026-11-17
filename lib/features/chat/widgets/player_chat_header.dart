import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

import 'chat_header_button.dart';
import 'organiser_avatar.dart';

/// The player's chat header, on the panel colour: back, the organiser's
/// "TX", "Organizatorul" and "{event} · {team}".
class PlayerChatHeader extends StatelessWidget {
  const PlayerChatHeader({super.key, required this.subtitle, required this.onBack});

  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.panel,
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 12, 8),
            child: Row(
              children: [
                ChatHeaderButton(
                  icon: TablerIcons.arrow_left,
                  iconSize: 22,
                  label: 'Înapoi',
                  colour: colors.text,
                  onTap: onBack,
                ),
                const SizedBox(width: 4),
                const OrganiserAvatar(size: 40, fontSize: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organizatorul',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.text),
                      ),
                      Text(
                        subtitle,
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
      ),
    );
  }
}
