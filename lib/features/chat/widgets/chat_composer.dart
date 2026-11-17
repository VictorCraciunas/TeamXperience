import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/misc/tap_area.dart';
import 'package:teamxperience/ui/theme/contrast.dart';
import 'package:teamxperience/ui/ui.dart';

/// The bottom of the chat: one rounded bar with the photo button, the field
/// ([hint]: "Scrie echipei…" / "Scrie organizatorului…") and the round send
/// button, greyed out until something is typed.
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSend,
    required this.onPhoto,
    this.sendingPhoto = false,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSend;
  final VoidCallback onPhoto;

  /// A spinner in the photo button while a picture goes out.
  final bool sendingPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.inset,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          // The buttons count as part of the field: sending keeps the keyboard
          // up for the next message (see TapOutsideClosesKeyboard).
          child: TextFieldTapRegion(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.panel,
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TapArea(
                    minSize: 44,
                    label: 'Trimite o poză',
                    onTap: sendingPhoto ? null : onPhoto,
                    child: sendingPhoto
                        ? SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.accent),
                          )
                        : Icon(TablerIcons.photo, size: 22, color: colors.muted),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(fontSize: 15, color: colors.text),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(fontSize: 15, color: colors.muted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      final hasText = value.text.trim().isNotEmpty;
                      final fill = hasText ? colors.accent : colors.border;
                      return TapArea(
                        minSize: 44,
                        label: 'Trimite',
                        onTap: hasText ? onSend : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
                          child: Icon(
                            TablerIcons.send,
                            size: 20,
                            color: hasText ? readableOn([colors.accent]) : colors.muted,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
