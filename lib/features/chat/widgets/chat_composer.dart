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
        border: Border(top: BorderSide(color: context.colors.liveCard.withValues(alpha: .04))),
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
                  color: context.colors.panel,
                  border: Border.all(
                    color: hasText ? context.colors.accent : context.colors.border,
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
                  color: hasText ? null : context.colors.border,
                  shape: BoxShape.circle,
                  boxShadow: hasText
                      ? [
                          BoxShadow(
                            color: context.colors.navy.withValues(alpha: .25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: hasText ? context.colors.onNavy : context.colors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
