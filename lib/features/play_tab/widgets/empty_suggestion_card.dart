import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import 'card_handle.dart';
import 'popup_button.dart';
import 'stagger_in.dart';
import 'suggestion_shell.dart';

/// Not registered and nothing open to suggest: only the way to Evenimente.
class EmptySuggestionCard extends StatelessWidget {
  const EmptySuggestionCard({super.key, required this.stagger, required this.onBrowseAll});

  final bool stagger;
  final VoidCallback onBrowseAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    var i = 0;
    Widget row(Widget child) => StaggerIn(index: i++, play: stagger, child: child);
    return SuggestionShell(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHandle(color: colors.border),
              row(Text(
                'Nu ești înscris la niciun joc',
                style: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w600, color: colors.text),
              )),
              row(Text('Nu e niciun joc deschis acum.', style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted))),
              const SizedBox(height: 6),
              row(PopupButton(label: 'Toate evenimentele', kind: PopupButtonKind.link, onPressed: onBrowseAll)),
            ],
          ),
        ),
      ],
    );
  }
}
