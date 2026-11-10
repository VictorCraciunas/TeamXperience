import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/fold_letters.dart';
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
    this.onDark = false,
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

  /// Navy boxes, as mockup 05's start code.
  final bool onDark;

  @override
  State<CodeBoxesInput> createState() => _CodeBoxesInputState();
}

class _CodeBoxesInputState extends State<CodeBoxesInput> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  /// The shake when the code turns out wrong.
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  /// Across the boxes: three swings that die down, ending in place.
  double _shakeOffset(double t) => math.sin(t * math.pi * 6) * 6 * (1 - t);

  @override
  void didUpdateWidget(CodeBoxesInput old) {
    super.didUpdateWidget(old);
    if (widget.error && !old.error && !MediaQuery.disableAnimationsOf(context)) {
      _shake.forward(from: 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  @override
  void dispose() {
    _shake.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _changed(String value) {
    widget.onChanged(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  /// Focuses the boxes, or, when they have focus already (the keyboard was
  /// closed with the back button), brings the keyboard back.
  void _openKeyboard() {
    if (_focus.hasFocus) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    } else {
      _focus.requestFocus();
    }
  }

  /// A long press pastes the clipboard: the same cleaning as typing.
  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final pasted = _clean(data?.text ?? '');
    if (!mounted || pasted.isEmpty) return;
    _controller.value = TextEditingValue(
      text: pasted,
      selection: TextSelection.collapsed(offset: pasted.length),
    );
    _focus.requestFocus();
    _changed(pasted);
  }

  String _clean(String raw) {
    final cleaned = foldLetters(raw).replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
    return cleaned.length > widget.length ? cleaned.substring(0, widget.length) : cleaned;
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
            onDark: widget.onDark,
          ),
        ),
      );
      if (widget.dashAfter == i + 1 && i + 1 < widget.length) {
        // The 6 px gaps either side come from the row's own spacing.
        boxes.add(const SizedBox(width: 6));
        boxes.add(
          Text(
            '-',
            style: TextStyle(
              fontFamily: 'Monospace',
              fontSize: 20,
              height: 1.45,
              color: (widget.onDark ? colors.onNavy : colors.text).withValues(alpha: 0.5),
            ),
          ),
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openKeyboard,
      onLongPress: _paste,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Narrow screens and large text scale the row down rather than overflow.
          AnimatedBuilder(
            animation: _shake,
            builder: (context, child) => Transform.translate(
              offset: Offset(_shake.isAnimating ? _shakeOffset(_shake.value) : 0, 0),
              child: child,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(mainAxisSize: MainAxisSize.min, children: boxes),
            ),
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
                  // Romanian letters become their plain letters before the filter.
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) => newValue.copyWith(text: foldLetters(newValue.text)),
                  ),
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
