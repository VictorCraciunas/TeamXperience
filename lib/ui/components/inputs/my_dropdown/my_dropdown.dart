import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import 'package:teamxperience/ui/components/inputs/my_dropdown/dropdown_item.dart';

/// A reusable labeled dropdown field that displays a label above
/// a custom dropdown button, with customizable styling and behavior.
class MyDropdownField<T> extends StatefulWidget {
  /// The list of dropdown items to display.
  final List<DropdownItem<T>> items;

  /// The currently selected value.
  final T? value;

  /// Callback function triggered when the selection changes.
  final void Function(T?)? onChanged;

  /// The text label displayed above the dropdown.
  final String labelText;

  /// Font size of the label.
  final double labelFontSize;

  /// Font weight of the label.
  final FontWeight labelFontWeight;

  /// Color of the dropdown's border.
  final Color borderColor;

  /// Width of the border when enabled.
  final double borderWidth;

  /// Radius of the border's corners.
  final double radius;

  /// Optional hint widget displayed when no value is selected.
  final Widget? hint;

  /// Optional validator function to validate the selection.
  final String? Function(T?)? validator;

  /// Optional widget displayed before the dropdown (prefix icon).
  final Widget? leading;

  /// Optional custom icon for the dropdown button (replaces the default arrow).
  final Widget? dropdownIcon;

  /// Padding inside the dropdown field.
  final EdgeInsets? contentPadding;

  const MyDropdownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.labelText,
    this.labelFontSize = 15,
    this.labelFontWeight = FontWeight.w500,
    this.borderColor = const Color(0xFFE6E6E6),
    this.borderWidth = 2,
    this.radius = 50,
    this.hint,
    this.validator,
    this.leading,
    this.dropdownIcon,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 12,
    ),
  });

  @override
  State<MyDropdownField<T>> createState() => _MyDropdownFieldState<T>();
}

class _MyDropdownFieldState<T> extends State<MyDropdownField<T>>
    with SingleTickerProviderStateMixin {
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String? _errorText;
  bool _isDisposed = false;
  late final AnimationController _chevronController;
  late final Animation<double> _chevronTurns;

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _chevronTurns = Tween(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _errorText != null
        ? const Color(0xFFE03A3A)
        : _isOpen
            ? context.colors.accent
            : widget.borderColor;
    final borderWidth = _isOpen ? 3.0 : widget.borderWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            fontSize: widget.labelFontSize,
            fontWeight: widget.labelFontWeight,
            color: context.colors.text,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          key: _dropdownKey,
          onTap: _toggleDropdown,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.contentPadding,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: borderWidth),
              borderRadius: BorderRadius.circular(widget.radius),
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: widget.leading,
                  ),
                ],
                Expanded(child: _buildSelectedItemDisplay()),
                widget.dropdownIcon ??
                    RotationTransition(
                      turns: _chevronTurns,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: context.colors.text,
                      ),
                    ),
              ],
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Color(0xFFE03A3A),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedItemDisplay() {
    if (widget.value != null) {
      final selectedItem = widget.items.firstWhere(
        (item) => item.value == widget.value,
        orElse: () => widget.items.first,
      );
      return Text(
        selectedItem.label,
        style: TextStyle(
          fontSize: 14,
          color: context.colors.text,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
    return widget.hint ??
        Text(
          'Selectează o opțiune',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.muted,
          ),
        );
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_overlayEntry != null) return;

    final renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = _createOverlayEntry(offset, size);
    Overlay.of(context).insert(_overlayEntry!);

    if (!_isDisposed) {
      setState(() => _isOpen = true);
      _chevronController.forward();
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (!_isDisposed) {
      setState(() => _isOpen = false);
      _chevronController.reverse();
    }
  }

  OverlayEntry _createOverlayEntry(Offset offset, Size size) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 8,
            width: size.width,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: context.colors.accent.withValues(alpha: 0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      color: context.colors.accent.withValues(alpha: 0.18),
                    ),
                    BoxShadow(
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      color: context.colors.text.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.items.map((item) {
                    final isSelected = item.value == widget.value;
                    return GestureDetector(
                      onTap: () => _selectItem(item.value),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colors.iconButtonBg
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: context.colors.text,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                color: context.colors.accent,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectItem(T value) {
    _closeDropdown();
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
    _validate(value);
  }

  void _validate(T? value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      if (!_isDisposed) {
        setState(() {
          _errorText = error;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _chevronController.dispose();
    super.dispose();
  }
}

