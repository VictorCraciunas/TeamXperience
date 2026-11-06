import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// Asks the organiser why a photo is rejected; the team reads the answer
/// ("Respinsă: „Nu se vede ceasul”"). Returns the trimmed reason, or null
/// when cancelled.
Future<String?> showRejectPhotoDialog(BuildContext context) {
  return showDialog<String>(context: context, builder: (_) => const RejectPhotoDialog());
}

class RejectPhotoDialog extends StatefulWidget {
  const RejectPhotoDialog({super.key});

  @override
  State<RejectPhotoDialog> createState() => _RejectPhotoDialogState();
}

class _RejectPhotoDialogState extends State<RejectPhotoDialog> {
  final TextEditingController _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = _reason.text.trim();
    return AlertDialog(
      backgroundColor: colors.panel,
      title: Text('Respinge poza', style: AppTextStyles.title(context)),
      content: TextField(
        controller: _reason,
        autofocus: true,
        maxLines: 3,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Motivul (îl vede echipa)'),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Anulează')),
        TextButton(
          onPressed: text.isEmpty ? null : () => Navigator.of(context).pop(text),
          style: TextButton.styleFrom(foregroundColor: colors.danger),
          child: const Text('Respinge'),
        ),
      ],
    );
  }
}
