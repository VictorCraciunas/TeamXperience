import 'package:flutter/widgets.dart';

/// Checks the form behind [form]. When a field is wrong, scrolls to the
/// highest wrong field on the page and returns its message ('' when it shows
/// none), so the screen can say what to fix. Null when every field is right.
/// A form that is not on screen counts as wrong.
Future<String?> revealFormError(
  GlobalKey<FormState> form, {
  Duration duration = const Duration(milliseconds: 300),
}) async {
  final state = form.currentState;
  if (state == null) return '';
  final wrong = state.validateGranularly();
  if (wrong.isEmpty) return null;

  FormFieldState<Object?> first = wrong.first;
  double? top;
  for (final field in wrong) {
    final box = field.context.findRenderObject();
    if (box is! RenderBox || !box.attached) continue;
    final y = box.localToGlobal(Offset.zero).dy;
    if (top == null || y < top) {
      top = y;
      first = field;
    }
  }
  final message = first.errorText ?? '';
  if (first.context.mounted) {
    await Scrollable.ensureVisible(first.context, duration: duration, alignment: 0.2);
  }
  return message;
}
