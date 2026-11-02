import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:teamxperience/utils/component_conversion/text_effects.dart';
import 'package:teamxperience/utils/event_fonts.dart';

/// What the unsettled letters are replaced with.
const _pool = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#\$%&*<>/{}[]=+-_@!?';

/// Characters that are never scrambled: the shape of the text stays readable.
const _kept = ' \n\t\r,.;:!?\'"()-';

/// [text] with the first [settled] characters as they are and every other
/// letter replaced by another one, picked by [seed] (the same seed gives the
/// same letters). Spaces and punctuation are kept in place.
String scrambleText(String text, int settled, int seed) {
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final character = text[i];
    if (i < settled || _kept.contains(character)) {
      buffer.write(character);
    } else {
      final random = math.Random(seed * 1000003 + i);
      buffer.write(_pool[random.nextInt(_pool.length)]);
    }
  }
  return buffer.toString();
}

/// A text that appears as scrambled letters which settle on the real ones, from
/// left to right, [msPerCharacter] for each. The room it takes is the room of
/// the finished text from the start, so nothing moves while it decodes. With
/// animations switched off in the phone settings the text is shown at once.
class DecodeText extends StatefulWidget {
  const DecodeText({
    super.key,
    required this.text,
    required this.textColor,
    required this.fontWeight,
    this.fontSize,
    this.fontFamily,
    this.msPerCharacter = 100,
    this.textAlign = TextAlign.center,
    this.effects = const TextEffects(),
  });

  final String text;
  final Color textColor;
  final FontWeight fontWeight;
  final double? fontSize;
  final String? fontFamily;
  final int msPerCharacter;
  final TextAlign textAlign;
  final TextEffects effects;

  @override
  State<DecodeText> createState() => _DecodeTextState();
}

class _DecodeTextState extends State<DecodeText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// How often the scrambled letters change.
  static const _refreshMs = 45;

  String get _shown => widget.effects.apply(widget.text);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _restart();
  }

  @override
  void didUpdateWidget(DecodeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.msPerCharacter != widget.msPerCharacter) _restart();
  }

  void _restart() {
    final length = _shown.length;
    _controller.duration = Duration(milliseconds: math.max(1, length * widget.msPerCharacter));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle get _style => widget.effects.style(
        TextStyle(
          color: widget.textColor,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: widget.fontFamily,
          fontVariations: fontVariationsFor(widget.fontFamily, widget.fontWeight),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final finished = _shown;
    final off = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Text text(String value, {TextStyle? style}) => Text(value, textAlign: widget.textAlign, style: style ?? _style);

    if (off || finished.isEmpty) return text(finished);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final elapsedMs = (_controller.value * _controller.duration!.inMilliseconds).round();
        final settled = (_controller.value * finished.length).floor();
        final visible = settled >= finished.length ? finished : scrambleText(finished, settled, elapsedMs ~/ _refreshMs);

        // The finished text keeps the room (invisible); the decoding is drawn over it.
        return Stack(
          children: [
            Opacity(opacity: 0, child: text(finished)),
            Positioned(left: 0, top: 0, right: 0, child: text(visible)),
          ],
        );
      },
    );
  }
}
