import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

import 'chat_header_button.dart';
import 'chat_mission_strip.dart';

/// The organiser's chat header, navy: back, the team's initial, its name
/// and members, "Arată echipa pe hartă" and "Sună căpitanul" (faded when the
/// team has no position or number), then the mission strip.
class OrganiserChatHeader extends StatelessWidget {
  const OrganiserChatHeader({
    super.key,
    required this.teamName,
    required this.teamInitial,
    required this.members,
    required this.onBack,
    required this.onMap,
    required this.onCall,
    this.strip,
  });

  final String teamName;
  final String teamInitial;

  /// "Ana, Radu, Mihai, Ioana"; hidden when empty.
  final String members;
  final VoidCallback onBack;
  final VoidCallback? onMap;
  final VoidCallback? onCall;
  final ({String text, int total, int done, int? current})? strip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shownStrip = strip;
    final round = colors.onNavy.withValues(alpha: .12);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: colors.navy,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 12, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ChatHeaderButton(
                      icon: TablerIcons.arrow_left,
                      iconSize: 22,
                      label: 'Înapoi',
                      colour: colors.onNavy,
                      onTap: onBack,
                    ),
                    const SizedBox(width: 4),
                    ExcludeSemantics(
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: colors.onNavyFaint, shape: BoxShape.circle),
                        child: Text(
                          teamInitial,
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.onNavy),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teamName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colors.onNavy),
                          ),
                          if (members.isNotEmpty)
                            Text(
                              members,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: colors.onNavy.withValues(alpha: .75)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChatHeaderButton(
                      icon: TablerIcons.map_pin,
                      label: 'Arată echipa pe hartă',
                      colour: colors.onNavy,
                      fill: round,
                      onTap: onMap,
                    ),
                    const SizedBox(width: 8),
                    ChatHeaderButton(
                      icon: TablerIcons.phone,
                      label: 'Sună căpitanul',
                      colour: colors.onNavy,
                      fill: round,
                      onTap: onCall,
                    ),
                  ],
                ),
                if (shownStrip != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChatMissionStrip(
                      text: shownStrip.text,
                      total: shownStrip.total,
                      done: shownStrip.done,
                      current: shownStrip.current,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
