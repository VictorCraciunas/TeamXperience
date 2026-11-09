import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The greeting for a player with no games yet: what the game is and a link
/// to how it works, instead of three boxes of zeros.
class NewPlayerGreeting extends StatelessWidget {
  const NewPlayerGreeting({super.key, required this.firstName, required this.onHow});

  final String firstName;
  final VoidCallback onHow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Salut, $firstName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
          ),
          const SizedBox(height: 4),
          Text(
            'Mergeți prin oraș, rezolvați indicii, descoperiți povestea.',
            style: TextStyle(fontSize: 12, height: 1.45, color: colors.muted),
          ),
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onHow,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Cum funcționează',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: colors.accent,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
