import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/ui.dart';

import 'events_tab_preview.dart';
import 'play_tab_preview.dart';

/// The gallery buttons that open the Evenimente and Joacă tabs with the
/// five-tab bar.
class ShellPreviewsLauncher extends StatelessWidget {
  const ShellPreviewsLauncher({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.page,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(label: 'Evenimente', onPressed: () => _open(context, const EventsTabPreview())),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Joacă', onPressed: () => _open(context, const PlayTabPreview())),
          ],
        ),
      ),
    );
  }
}
