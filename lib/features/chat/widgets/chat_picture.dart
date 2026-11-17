import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

import 'full_screen_image.dart';

/// A chat picture, [height] tall with rounded corners; a tap opens it full
/// screen.
class ChatPicture extends StatelessWidget {
  const ChatPicture({super.key, required this.url, required this.height});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget placeholder(Widget child) =>
        Container(color: colors.insetBorder, alignment: Alignment.center, child: child);
    return Semantics(
      image: true,
      button: true,
      label: 'Poza, deschide mare',
      child: GestureDetector(
        onTap: url.isEmpty
            ? null
            : () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => FullScreenImage(imageUrl: url))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: url.isEmpty
                ? placeholder(Icon(TablerIcons.photo, color: colors.muted))
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : placeholder(CircularProgressIndicator(color: colors.accent)),
                    errorBuilder: (context, error, stack) => placeholder(Icon(Icons.broken_image, color: colors.muted)),
                  ),
          ),
        ),
      ),
    );
  }
}
