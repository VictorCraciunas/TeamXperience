import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// The mockups' `.btn`: a full-width navy button with a 12 radius, 11 px of
/// padding and a medium-weight label. With [onPressed] null it is greyed out;
/// with [isLoading] it shows a spinner and ignores taps.
class NavyButton extends StatelessWidget {
  const NavyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    final active = enabled || isLoading;
    final radius = BorderRadius.circular(AppRadius.button);
    final foreground = active ? colors.onNavy : colors.muted;

    return Semantics(
      button: true,
      enabled: enabled && !isLoading,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: active ? colors.navy : colors.insetBorder,
            borderRadius: radius,
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: isLoading ? null : onPressed,
            // At least 44 px tall, the app's smallest main control.
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Center(
                  heightFactor: 1,
                  child:
                      isLoading
                          ? SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: foreground,
                            ),
                          )
                          : Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle(
                              context,
                            ).copyWith(color: foreground),
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
