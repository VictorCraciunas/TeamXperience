import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';

/// The top of the Echipe screen, as in mockup 03: the title and, at the
/// right, the chip that starts a new team.
class TeamsHeader extends StatelessWidget {
  const TeamsHeader({super.key, required this.onNewCrew});

  final VoidCallback onNewCrew;

  @override
  Widget build(BuildContext context) {
    return TabHeader(
      title: 'Echipe',
      trailing: AppChip(label: 'Echipă nouă', icon: TablerIcons.plus, onTap: onNewCrew),
    );
  }
}
