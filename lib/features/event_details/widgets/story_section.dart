import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The story, folded to three lines with "Citește tot" when it is longer.
class StorySection extends StatefulWidget {
  const StorySection({super.key, required this.text});

  final String text;

  @override
  State<StorySection> createState() => _StorySectionState();
}

class _StorySectionState extends State<StorySection> {
  static const _foldedLines = 3;
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.pageBody(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _foldedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final long = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: style,
              maxLines: _open ? null : _foldedLines,
              overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (long)
              GestureDetector(
                onTap: () => setState(() => _open = !_open),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    _open ? 'Mai puțin' : 'Citește tot',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: context.colors.accent,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
