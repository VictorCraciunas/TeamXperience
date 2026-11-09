import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/components/team/invite_code_card.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// What the register screen shows under the form once the team is made: the
/// navy invite card with the code to send on, and "1 din 4 în echipă" under
/// the buttons. [code] is shown as given ("VLP-482").
class InviteResultSection extends StatelessWidget {
  const InviteResultSection({
    super.key,
    required this.code,
    required this.size,
    required this.initials,
    this.leftOut = const [],
    required this.onShare,
    required this.onCopy,
  });

  final String code;

  /// How many places the team has, the captain's included.
  final int size;

  /// Who is in the team so far.
  final List<String> initials;

  /// The crew's names left out, because they are in another team of the event.
  final List<String> leftOut;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: InviteCodeCard(
        code: code,
        caption: 'Gata. Trimite codul coechipierilor',
        shareLabel: 'WhatsApp',
        copyLabel: 'Copiază',
        onShare: onShare,
        onCopy: onCopy,
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarStack(initials: initials, total: size, onDark: true),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${initials.length} din $size în echipă',
                    style: TextStyle(fontSize: 13, height: 1.45, color: colors.onNavy.withValues(alpha: .8)),
                  ),
                ),
              ],
            ),
            if (leftOut.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Sunt deja în altă echipă la acest eveniment: ${leftOut.join(', ')}.',
                  style: TextStyle(fontSize: 13, height: 1.45, color: colors.onNavy.withValues(alpha: .8)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
