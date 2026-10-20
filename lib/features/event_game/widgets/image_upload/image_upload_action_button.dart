import 'package:flutter/material.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

class ImageUploadActionButton extends StatelessWidget {
  final PhotoApprovalStatus? status;
  final bool isUploading;
  final VoidCallback onContinue;
  final VoidCallback onReupload;

  const ImageUploadActionButton({
    super.key,
    required this.status,
    required this.isUploading,
    required this.onContinue,
    required this.onReupload,
  });

  @override
  Widget build(BuildContext context) {
    if (isUploading) return const SizedBox.shrink();

    switch (status) {
      case PhotoApprovalStatus.approved:
        return AppButton(label: 'Continuă', onPressed: onContinue);
      case PhotoApprovalStatus.denied:
        return AppButton(label: 'Încarcă altă poză', onPressed: onReupload);
      case PhotoApprovalStatus.pending:
      case null:
        return const SizedBox.shrink();
    }
  }
}
