import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Nu ai codul? Scrie-i organizatorului" under the start button (mockup
/// 05); opens the team chat.
class StartChatLink extends StatelessWidget {
  const StartChatLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.onNavy.withValues(alpha: .7);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(TablerIcons.message_circle, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'Nu ai codul? Scrie-i organizatorului',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.45, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
