import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/buttons/navy_button.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';

/// The button that joins the team and the line under it. [onJoin] is null
/// while the button must stay greyed out; [joining] shows its spinner.
class JoinBottomBlock extends StatelessWidget {
  const JoinBottomBlock({
    super.key,
    required this.label,
    required this.onJoin,
    required this.joining,
  });

  final String label;
  final VoidCallback? onJoin;
  final bool joining;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavyButton(label: label, onPressed: onJoin, isLoading: joining),
          const SizedBox(height: 8),
          Text(
            'Evenimentul apare la Înscrierile tale și primești notificări.',
            textAlign: TextAlign.center,
            style: AppTextStyles.smallMuted(context),
          ),
        ],
      ),
    );
  }
}
