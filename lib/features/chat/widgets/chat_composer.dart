import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool hasText;

  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.hasText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: context.colors.panel,
        border: Border(top: BorderSide(color: Color(0x0A0C092A))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                constraints: const BoxConstraints(minHeight: 50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: hasText ? context.colors.accent : const Color(0xFFE6E6E6),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Trimite un mesaj…',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: context.colors.muted,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: hasText ? onSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: hasText ? context.colors.ctaGradient : null,
                  color: hasText ? null : const Color(0xFFE6E6E6),
                  shape: BoxShape.circle,
                  boxShadow: hasText
                      ? const [
                          BoxShadow(
                            color: Color(0x40222F62),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: hasText ? Colors.white : const Color(0xFFBBBBBB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
