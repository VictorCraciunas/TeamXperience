import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_thumbnail.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_type_pill.dart';
import 'package:teamxperience/ui/ui.dart';

/// A news on the organiser's list: picture, title, the Publică / Privată
/// pill with "{category} · {date}", and a round edit button. A tap opens the
/// news; a long press (or the screen reader's "Șterge știrea") asks to delete it.
class AdminNewsRow extends StatelessWidget {
  const AdminNewsRow({
    super.key,
    required this.title,
    required this.typeLabel,
    required this.isPrivate,
    required this.meta,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.imageUrl,
  });

  final String title;
  final String typeLabel;
  final bool isPrivate;
  final String meta;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? imageUrl;

  static const _deleteAction = CustomSemanticsAction(label: 'Șterge știrea');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      customSemanticsActions: {_deleteAction: onDelete},
      child: Material(
        color: colors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onDelete,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                NewsThumbnail(url: imageUrl, width: 64, height: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: colors.text),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 6,
                        runSpacing: 3,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          NewsTypePill(label: typeLabel, isPrivate: isPrivate),
                          Text(meta, style: TextStyle(fontSize: 12, color: colors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Editează știrea',
                  child: Material(
                    color: colors.iconButtonBg,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onEdit,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(TablerIcons.pencil, size: 18, color: colors.accent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
