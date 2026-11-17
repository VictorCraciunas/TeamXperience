import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

import '../logic/chat_button_texts.dart';

/// A new organiser message above the chat button: "Organizator · acum" and
/// the text on at most two lines. Tapping it opens the chat.
class ChatPreviewBubble extends StatelessWidget {
  const ChatPreviewBubble({super.key, required this.text, required this.onTap, this.maxWidth = 250});

  final String text;
  final VoidCallback onTap;
  final double maxWidth;

  static const _radius = BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
    bottomLeft: Radius.circular(16),
    bottomRight: Radius.circular(4),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      liveRegion: true,
      label: 'Mesaj nou de la organizator: $text',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, minHeight: 44),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _radius,
            boxShadow: [BoxShadow(color: colors.text.withValues(alpha: .12), blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: Material(
            color: colors.panel,
            shape: RoundedRectangleBorder(borderRadius: _radius, side: BorderSide(color: colors.border)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const ValueKey('chat-preview-bubble'),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(previewHeader, style: TextStyle(fontSize: 12, height: 1.45, color: colors.muted)),
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, height: 1.45, color: colors.text),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
