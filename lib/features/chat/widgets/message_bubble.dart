import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'bubble_position.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final BubblePosition position;
  final String? time;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.position = BubblePosition.single,
    this.time,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: showTime ? 12 : 2),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isMe ? context.colors.ctaGradient : null,
              color: isMe ? null : context.colors.panel,
              border: isMe
                  ? null
                  : Border.all(color: context.colors.border, width: 1.5),
              borderRadius: bubbleRadius(isMe, position),
              boxShadow: [
                if (isMe)
                  BoxShadow(
                    color: context.colors.navy.withValues(alpha: .18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: context.colors.liveCard.withValues(alpha: .04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: isMe ? context.colors.onNavy : context.colors.text,
                height: 1.45,
              ),
            ),
          ),
          if (showTime && time != null)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                right: isMe ? 8 : 0,
                left: isMe ? 0 : 8,
              ),
              child: Text(
                time!,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: context.colors.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
