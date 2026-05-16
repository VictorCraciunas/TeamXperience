import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
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
              gradient: isMe ? MyColors.myGradient : null,
              color: isMe ? null : MyColors.barColor,
              border: isMe
                  ? null
                  : Border.all(color: const Color(0xFFE6E6E6), width: 1.5),
              borderRadius: bubbleRadius(isMe, position),
              boxShadow: [
                if (isMe)
                  const BoxShadow(
                    color: Color(0x2E222F62),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  )
                else
                  const BoxShadow(
                    color: Color(0x0A0C092A),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: isMe ? Colors.white : MyColors.blackColor,
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
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: MyColors.greyText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
