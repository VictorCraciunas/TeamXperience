import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// Asks for one line of text. Returns the trimmed text, or null when
/// cancelled. Confirming with an empty field keeps the dialog open.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String cancelLabel = 'Anulează',
  String emptyMessage = 'Scrie un nume',
  String initialText = '',
}) {
  return showDialog<String>(
    context: context,
    builder:
        (_) => _TextInputDialog(
          title: title,
          label: label,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          emptyMessage: emptyMessage,
          initialText: initialText,
        ),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.emptyMessage,
    required this.initialText,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String cancelLabel;
  final String emptyMessage;
  final String initialText;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialText);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = widget.emptyMessage);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(
          color: colors.text,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _confirm(),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        style: TextStyle(color: colors.text),
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: _error,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.tick, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            widget.cancelLabel,
            style: TextStyle(color: colors.muted),
          ),
        ),
        TextButton(
          onPressed: _confirm,
          child: Text(
            widget.confirmLabel,
            style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
