import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/chat_timeline.dart';
import 'chat_avatar_view.dart';

/// Where a message sits: mine on the right; someone else's on the left with
/// a 32 px place for the avatar (drawn on the last of a run, level with the
/// bottom), the name above and the footer under. At most 75 % of the width.
class ChatMessageRow extends StatelessWidget {
  const ChatMessageRow({
    super.key,
    required this.mine,
    required this.child,
    this.avatar,
    this.name,
    this.footer,
  });

  static const double avatarSize = 32;
  static const double avatarGap = 8;

  final bool mine;
  final Widget child;
  final ChatAvatar? avatar;
  final String? name;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final small = AppTextStyles.caption(context).copyWith(fontSize: 12, color: context.colors.muted);
    final shownName = name;
    final shownFooter = footer;
    final shownAvatar = avatar;
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (shownName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(shownName, style: small, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        child,
        if (shownFooter != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(shownFooter, style: small, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
    );

    return LayoutBuilder(builder: (context, constraints) {
      final widest = constraints.maxWidth * 0.75;
      if (mine) {
        return Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(constraints: BoxConstraints(maxWidth: widest), child: column),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: avatarSize,
            child: shownAvatar == null ? null : ChatAvatarView(avatar: shownAvatar),
          ),
          const SizedBox(width: avatarGap),
          Flexible(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: widest), child: column)),
        ],
      );
    });
  }
}
