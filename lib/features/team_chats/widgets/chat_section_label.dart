import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Necitite" or "Citite" above its rows: small, muted, plain.
class ChatSectionLabel extends StatelessWidget {
  const ChatSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4, color: context.colors.muted),
      ),
    );
  }
}
