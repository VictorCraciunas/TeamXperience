import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leading,
    this.isLoading = false,
    this.expand = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? leading;
  final bool isLoading;
  final bool expand;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(AppRadius.button);

    final customBackground = backgroundColor;
    final Color foreground;
    BoxDecoration decoration;
    if (!enabled && onPressed == null) {
      foreground = colors.muted;
      decoration = BoxDecoration(
        color: colors.insetBorder,
        borderRadius: radius,
      );
    } else if (customBackground != null) {
      foreground = foregroundColor ?? Colors.white;
      decoration = BoxDecoration(color: customBackground, borderRadius: radius);
    } else {
      switch (variant) {
        case AppButtonVariant.primary:
          foreground = Colors.white;
          decoration = BoxDecoration(
            gradient: colors.ctaGradient,
            borderRadius: radius,
          );
        case AppButtonVariant.secondary:
          foreground = colors.accent;
          decoration = BoxDecoration(
            border: Border.all(color: colors.accent, width: 1.5),
            borderRadius: radius,
          );
        case AppButtonVariant.ghost:
          foreground = colors.accent;
          decoration = BoxDecoration(borderRadius: radius);
      }
    }

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
            ),
          )
        else if (leading != null)
          IconTheme(
            data: IconThemeData(color: foreground, size: 20),
            child: leading ?? const SizedBox.shrink(),
          ),
        if (isLoading || leading != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: decoration,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onPressed : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
