import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/contrast.dart';
import 'package:teamxperience/ui/ui.dart';

/// The red pill with how many things wait in a chat; "99+" past 99.
class ChatCountBadge extends StatelessWidget {
  const ChatCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final fill = context.colors.live;
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, color: readableOn([fill])),
      ),
    );
  }
}
