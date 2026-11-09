import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// The small card offering a team photo: a camera or the photo taken, the
/// texts and a button. Optional by design, so it never blocks what is below
/// it. The start and finish screens give it their own colours.
class TeamPhotoPrompt extends StatelessWidget {
  const TeamPhotoPrompt({
    super.key,
    this.photoUrl,
    required this.title,
    this.line,
    required this.busy,
    this.error,
    required this.onTake,
    required this.fill,
    required this.textColor,
    required this.softColor,
    required this.errorColor,
    required this.buttonFill,
    required this.buttonText,
  });

  final String? photoUrl;
  final String title;

  /// Under the title; left out once there is a photo.
  final String? line;
  final bool busy;
  final String? error;
  final VoidCallback onTake;
  final Color fill;
  final Color textColor;
  final Color softColor;
  final Color errorColor;
  final Color buttonFill;
  final Color buttonText;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final camera = ColoredBox(
      color: buttonFill,
      child: Center(child: Icon(TablerIcons.camera, size: 22, color: buttonText)),
    );
    final note = line;
    final failure = error;
    return DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox.square(
                dimension: _size,
                child: url == null
                    ? camera
                    : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => camera),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.45, color: textColor)),
                  if (note != null && url == null) Text(note, style: TextStyle(fontSize: 11, height: 1.45, color: softColor)),
                  if (failure != null) Text(failure, style: TextStyle(fontSize: 11, height: 1.45, color: errorColor)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: busy ? null : onTake,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _size, minWidth: _size),
                  child: Center(
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: buttonFill, borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: busy
                            ? SizedBox.square(
                                dimension: 17,
                                child: CircularProgressIndicator(strokeWidth: 2, color: buttonText),
                              )
                            : Text(
                                url == null ? 'Fă poza' : 'Refă poza',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.45, color: buttonText),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
