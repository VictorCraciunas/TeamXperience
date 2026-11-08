import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/features/teams/widgets/crew_card.dart';
import 'package:teamxperience/features/teams/widgets/join_link.dart';
import 'package:teamxperience/features/teams/widgets/teams_header.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The Echipe screen drawn from its crews, as in mockup 03: the header with
/// "Echipă nouă", a navy card for each crew and the link for a code from
/// another team. [myUid] is the signed-in player; the cards do not use it yet.
class TeamsView extends StatelessWidget {
  const TeamsView({
    super.key,
    required this.crews,
    required this.myUid,
    required this.onNewCrew,
    required this.onJoin,
    required this.onShare,
    required this.onCopy,
    required this.onRetry,
    this.loading = false,
    this.failed = false,
  });

  final List<Crew> crews;
  final String myUid;
  final VoidCallback onNewCrew;
  final VoidCallback onJoin;
  final void Function(Crew) onShare;
  final void Function(Crew) onCopy;
  final VoidCallback onRetry;

  /// Waiting for the first answer: a spinner stands in for the crews.
  final bool loading;

  /// The crews could not be loaded: a message with a retry link stands in
  /// for them. The header and the join card stay either way.
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TeamsHeader(onNewCrew: onNewCrew),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (failed)
                LoadFailed(message: 'Nu am putut încărca echipele.', onRetry: onRetry)
              else if (crews.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 28, 14, 6),
                  child: Text(
                    'Nu ești încă într-o echipă.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pageBody(
                      context,
                    ).copyWith(color: context.colors.muted),
                  ),
                ),
              for (final crew in crews)
                CrewCard(
                  key: ValueKey(crew.id),
                  crew: crew,
                  onShare: () => onShare(crew),
                  onCopy: () => onCopy(crew),
                ),
              JoinLink(onJoin: onJoin),
            ],
          ),
        ),
      ],
    );
  }
}
