import 'package:flutter/material.dart';

/// Closes the keyboard the way phone users expect, for every text field under
/// it (MaterialApp's `builder` puts it around the whole app):
///
/// * a touch anywhere outside the text fields takes the focus away, so the
///   keyboard goes down. iPhone number pads have no close key, and Flutter
///   only does this for a mouse on phones. The touch still reaches whatever
///   was under it, so buttons, chips and links work on the first tap, and
///   tapping from one field to another keeps the keyboard up. Wrap a control
///   in [TextFieldTapRegion] to count it as part of a field (the code boxes,
///   the chat's send button);
/// * dragging a list closes it too, unless a list asks otherwise.
class TapOutsideClosesKeyboard extends StatelessWidget {
  const TapOutsideClosesKeyboard({super.key, required this.child});

  final Widget child;

  static void _unfocus(EditableTextTapOutsideIntent intent) => intent.focusNode.unfocus();

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        // Every EditableText asks its ancestors for this action before using
        // its own, which leaves touches on phones alone.
        EditableTextTapOutsideIntent: CallbackAction<EditableTextTapOutsideIntent>(onInvoke: _unfocus),
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        ),
        child: child,
      ),
    );
  }
}
