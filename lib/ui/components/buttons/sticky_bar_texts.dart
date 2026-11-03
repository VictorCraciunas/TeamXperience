import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// The status side of a [StickyActionBar]: a title, and a detail either on a
/// second line or after the title ("Vulpile · 4 membri").
class StickyBarTexts extends StatelessWidget {
  const StickyBarTexts({super.key, required this.title, this.detail, this.inline = false});

  final String title;
  final String? detail;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final extra = detail;
    final titleStyle = AppTextStyles.cardTitle(context);
    if (extra == null) return Text(title, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis);

    if (inline) {
      return Text.rich(
        TextSpan(children: [
          TextSpan(text: title, style: titleStyle),
          TextSpan(text: ' · $extra', style: AppTextStyles.pageBody(context).copyWith(color: context.colors.muted)),
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
        Text(extra, style: AppTextStyles.smallMuted(context), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
