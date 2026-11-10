import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/ui.dart';

import 'event_page_preview.dart';

/// The gallery button that opens the whole event page.
class EventPagePreviewLauncher extends StatelessWidget {
  const EventPagePreviewLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.page,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: AppButton(
          label: 'Pagina evenimentului',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventPagePreview())),
        ),
      ),
    );
  }
}
