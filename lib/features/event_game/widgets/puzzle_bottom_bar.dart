import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/game/game_icon_button.dart';
import 'package:teamxperience/ui/components/game/game_outline_button.dart';

/// The bottom of a puzzle: "Indiciu" (greyed when there is none to open) and
/// the chat with the organiser. The organiser's own button checks answers.
class PuzzleBottomBar extends StatelessWidget {
  const PuzzleBottomBar({super.key, required this.onHint, required this.onChat});

  final VoidCallback? onHint;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Row(
        children: [
          Expanded(child: GameOutlineButton(label: 'Indiciu', icon: TablerIcons.bulb, onTap: onHint)),
          const SizedBox(width: 8),
          GameIconButton(icon: TablerIcons.message_circle, label: 'Chat cu organizatorul', onTap: onChat),
        ],
      ),
    );
  }
}
