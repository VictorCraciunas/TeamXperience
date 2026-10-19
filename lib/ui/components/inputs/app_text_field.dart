import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.required = false,
    this.validator,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.inputFormatters,
    this.textInputAction,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final bool required;
  final String? Function(String?)? validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;
  String? _error;

  String? _validate(String? value) {
    final message = widget.validator?.call(value);
    if (message != _error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _error = message);
      });
    }
    return message;
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget? _suffix() {
    final colors = context.colors;
    if (widget.obscure) {
      return IconButton(
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: colors.muted,
        ),
        onPressed: () => setState(() => _hidden = !_hidden),
      );
    }
    if (_error != null) {
      return Icon(Icons.error_outline, color: colors.live);
    }
    return widget.trailing;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = TextStyle(
      color: colors.text,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    final label = widget.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text.rich(
            TextSpan(
              text: label,
              style: labelStyle,
              children: [
                if (widget.required)
                  TextSpan(text: ' *', style: TextStyle(color: colors.live)),
              ],
            ),
            key: const ValueKey('app-text-field-label'),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: _hidden ? 1 : widget.maxLines,
          obscureText: _hidden,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          validator: _validate,
          style: TextStyle(color: colors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: colors.muted, fontSize: 14),
            helperText: widget.helper,
            helperStyle: TextStyle(color: colors.muted, fontSize: 11),
            errorStyle: TextStyle(color: colors.live, fontSize: 11),
            filled: true,
            fillColor: colors.panel,
            prefixIcon: widget.leading,
            suffixIcon: _suffix(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: _border(colors.border, 1.5),
            enabledBorder: _border(colors.border, 1.5),
            focusedBorder: _border(colors.tick, 2),
            errorBorder: _border(colors.live, 1.5),
            focusedErrorBorder: _border(colors.live, 2),
          ),
        ),
      ],
    );
  }
}
