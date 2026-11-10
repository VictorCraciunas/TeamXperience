import 'package:flutter/material.dart';
import 'package:teamxperience/service/team_service/team_errors.dart';
import 'package:teamxperience/ui/components/buttons/navy_button.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/components/inputs/register_input.dart';
import 'package:teamxperience/ui/components/team/invite_code_card.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';
import 'package:teamxperience/utils/team_names.dart';

/// The bottom sheet behind "Echipă nouă": a name and "Creează". Once the crew
/// is made the sheet shows its invite code to send on.
class NewCrewSheet extends StatefulWidget {
  const NewCrewSheet({
    super.key,
    required this.onCreate,
    required this.onShare,
    required this.onCopy,
  });

  /// Makes the crew and returns its invite code as shown ("VLP-482"). Throws
  /// when the crew could not be made.
  final Future<String> Function(String name) onCreate;
  final void Function(String name, String code) onShare;
  final void Function(String code) onCopy;

  @override
  State<NewCrewSheet> createState() => _NewCrewSheetState();
}

class _NewCrewSheetState extends State<NewCrewSheet> {
  final _name = TextEditingController();
  bool _creating = false;
  String? _problem;

  /// Set once the crew is made.
  String? _code;
  String _madeName = '';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => teamNameProblem(_name.text) == null;

  Future<void> _create() async {
    if (!_valid || _creating) return;
    final name = cleanTeamName(_name.text);
    setState(() {
      _creating = true;
      _problem = null;
    });

    try {
      final code = await widget.onCreate(name);
      if (!mounted) return;
      setState(() {
        _code = code;
        _madeName = name;
        _creating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _problem = teamErrorText(TeamError.fromException(e));
        _creating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _code;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                code == null ? 'Echipă nouă' : _madeName,
                style: AppTextStyles.trailHeading(context),
              ),
              const SizedBox(height: 12),
              if (code == null) ...[
                RegisterInput(
                  controller: _name,
                  onChanged: (_) => setState(() => _problem = null),
                  hint: 'Numele echipei',
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 10),
                  child: FieldStatusLine(
                    text: _problem ?? 'Între 2 și 30 de caractere',
                    status:
                        _problem == null
                            ? FieldStatus.neutral
                            : FieldStatus.problem,
                  ),
                ),
                NavyButton(
                  label: 'Creează',
                  isLoading: _creating,
                  onPressed: _valid ? _create : null,
                ),
              ] else ...[
                InviteCodeCard(
                  code: code,
                  caption: 'Gata. Trimite codul coechipierilor',
                  shareLabel: 'Trimite',
                  copyLabel: 'Copiază',
                  onShare: () => widget.onShare(_madeName, code),
                  onCopy: () => widget.onCopy(code),
                ),
                const SizedBox(height: 10),
                Text(
                  'Îl găsești oricând la Echipe.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.smallMuted(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
