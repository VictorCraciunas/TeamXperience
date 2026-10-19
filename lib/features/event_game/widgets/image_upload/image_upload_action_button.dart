import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';

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
        return MyButton(
          buttonText: 'Continuă',
          textColor: Colors.white,
          buttonOnTap: onContinue,
          withBorder: false,
          gradient: MyColors.myGradient,
          buttonTextSize: 15,
        );
      case PhotoApprovalStatus.denied:
        return MyButton(
          buttonText: 'Încarcă altă poză',
          textColor: Colors.white,
          buttonOnTap: onReupload,
          withBorder: false,
          gradient: MyColors.myGradient,
          buttonTextSize: 15,
        );
      case PhotoApprovalStatus.pending:
      case null:
        return const SizedBox.shrink();
    }
  }
}
