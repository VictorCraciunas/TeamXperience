import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_details/logic/event_page_content.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';

import 'mission_teaser_row.dart';
import 'secret_missions_row.dart';

/// "Ce vă așteaptă": the public missions and the secret ones in one card.
class MissionTeaserCard extends StatelessWidget {
  const MissionTeaserCard({super.key, required this.shown, required this.secret});

  final List<MissionTeaser> shown;
  final int secret;

  @override
  Widget build(BuildContext context) {
    return OutlineCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < shown.length; i++)
            MissionTeaserRow(teaser: shown[i], divider: i < shown.length - 1 || secret > 0),
          if (secret > 0) SecretMissionsRow(count: secret),
        ],
      ),
    );
  }
}
