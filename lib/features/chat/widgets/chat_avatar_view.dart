import 'package:flutter/material.dart';

import '../logic/chat_timeline.dart';
import 'initials_avatar.dart';
import 'organiser_avatar.dart';

/// A [ChatAvatar] drawn: the organiser's "TX" or a player's initials.
class ChatAvatarView extends StatelessWidget {
  const ChatAvatarView({super.key, required this.avatar});

  final ChatAvatar avatar;

  @override
  Widget build(BuildContext context) {
    final initials = avatar.initials;
    return initials == null ? const OrganiserAvatar() : InitialsAvatar(initials: initials);
  }
}
