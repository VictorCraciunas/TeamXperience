import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import 'dropdown_item.dart';

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

class _MyDropdownFieldState<T> extends State<MyDropdownField<T>> {
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String? _errorText;
  bool _isDisposed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: widget.labelFontSize,
            fontWeight: widget.labelFontWeight,
            color: MyColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          key: _dropdownKey,
          onTap: _toggleDropdown,
          child: Container(
            padding: widget.contentPadding,
            decoration: BoxDecoration(
              border: Border.all(
                color: _errorText != null ? Colors.red : widget.borderColor,
                width: widget.borderWidth,
              ),
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
                Expanded(
                  child: _buildSelectedItemDisplay(),
                ),
                widget.dropdownIcon ??
                    Icon(
                      _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: MyColors.blackColor,
                    ),
              ],
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            _errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontFamily: 'Poppins',
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
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
          color: MyColors.blackColor,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      return widget.hint ?? const Text(
        'Select an option',
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
          color: MyColors.greyText,
        ),
      );
    }
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

    final RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = _createOverlayEntry(offset, size);
    Overlay.of(context).insert(_overlayEntry!);

    if (!_isDisposed) {
      setState(() {
        _isOpen = true;
      });
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (!_isDisposed) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry(Offset offset, Size size) {
    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  color: Colors.black26,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == widget.items.length - 1;

                  return InkWell(
                    onTap: () {
                      _selectItem(item.value);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: !isLast
                            ? const Border(
                          bottom: BorderSide(
                            color: MyColors.transparentLightBlue,
                            width: 1,
                          ),
                        )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: MyColors.blackColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
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
    // Remove overlay without calling setState
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }
}

