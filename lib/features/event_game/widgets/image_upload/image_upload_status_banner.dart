import 'package:flutter/material.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/ui/ui.dart';

class ImageUploadStatusBanner extends StatelessWidget {
  final PhotoApprovalStatus? status;
  final bool isUploading;

  const ImageUploadStatusBanner({
    super.key,
    required this.status,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isUploading) {
      return CircularProgressIndicator(color: colors.accent);
    }

    switch (status) {
      case PhotoApprovalStatus.pending:
        return _banner(
          'Se așteaptă aprobarea organizatorului...',
          colors.warning,
          colors.warningSoft,
        );
      case PhotoApprovalStatus.approved:
        return _banner(
          'Imaginea a fost aprobată!',
          colors.success,
          colors.successSoft,
        );
      case PhotoApprovalStatus.denied:
        return _banner(
          'Imaginea a fost respinsă. Încarcă alta.',
          colors.danger,
          colors.dangerSoft,
        );
      case null:
        return const SizedBox.shrink();
    }
  }

  Widget _banner(String text, Color color, Color background) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
