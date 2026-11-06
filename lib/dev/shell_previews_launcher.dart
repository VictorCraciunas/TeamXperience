import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/ui.dart';

import 'events_tab_preview.dart';
import 'game_intro_preview.dart';
import 'home_preview.dart';
import 'play_tab_preview.dart';
import 'puzzle_frame_preview.dart';
import 'route_preview.dart';
import 'start_code_preview.dart';

/// The gallery buttons that open the Acasă, Evenimente and Joacă tabs with the
/// five-tab bar, the start code, the intro letter, the route and a puzzle.
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
            AppButton(label: 'Acasă', onPressed: () => _open(context, const HomePreview())),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Evenimente', onPressed: () => _open(context, const EventsTabPreview())),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Joacă', onPressed: () => _open(context, const PlayTabPreview())),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Cod de start', onPressed: () => _open(context, const StartCodePreview())),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Scrisoarea', onPressed: () => _open(context, const GameIntroPreview())),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Traseu', onPressed: () => _open(context, const RoutePreview())),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Puzzle', onPressed: () => _open(context, const PuzzleFramePreview())),
          ],
        ),
      ),
    );
  }
}
