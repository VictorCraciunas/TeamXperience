import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme_context.dart';
import 'code_box.dart';

/// A code typed into one box per character ("VLP-482"). A single invisible
/// text field takes the typing, so paste, backspace and the keyboard work as
/// in any field; letters are upper-cased and anything that is not a letter or
/// digit is dropped.
class CodeBoxesInput extends StatefulWidget {
  const CodeBoxesInput({
    super.key,
    required this.length,
    this.dashAfter,
    required this.onChanged,
    this.onCompleted,
    this.error = false,
    this.keyboardType = TextInputType.text,
  });

  final int length;

  /// Draws a dash after this many boxes.
  final int? dashAfter;
  final ValueChanged<String> onChanged;

  /// Called with the full code when the last box is filled.
  final ValueChanged<String>? onCompleted;

  /// Draws every box with the danger colour.
  final bool error;
  final TextInputType keyboardType;

  @override
  State<CodeBoxesInput> createState() => _CodeBoxesInputState();
}

class _CodeBoxesInputState extends State<CodeBoxesInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _changed(String value) {
    widget.onChanged(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = _controller.text;
    final activeIndex = text.length < widget.length ? text.length : widget.length - 1;

    final boxes = <Widget>[];
    for (var i = 0; i < widget.length; i++) {
      if (i > 0) boxes.add(const SizedBox(width: 6));
      boxes.add(
        KeyedSubtree(
          key: ValueKey('code-box-$i'),
          child: CodeBox(
            character: i < text.length ? text[i] : '',
            active: _focus.hasFocus && i == activeIndex,
            error: widget.error,
          ),
        ),
      );
      if (widget.dashAfter == i + 1 && i + 1 < widget.length) {
        boxes.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '-',
              style: TextStyle(fontFamily: 'Monospace', fontSize: 20, color: colors.muted),
            ),
          ),
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focus.requestFocus,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Narrow screens and large text scale the row down rather than overflow.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: boxes),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: widget.keyboardType,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                enableInteractiveSelection: false,
                showCursor: false,
                cursorWidth: 0,
                style: const TextStyle(color: Colors.transparent, fontSize: 1),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isCollapsed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase()),
                  ),
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                onChanged: _changed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
