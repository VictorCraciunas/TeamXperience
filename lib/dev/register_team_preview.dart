import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/register_team/widgets/invite_result_section.dart';
import 'package:teamxperience/features/register_team/widgets/register_form.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/components/navigation/screen_bar.dart';
import 'package:teamxperience/ui/ui.dart';

/// The register screen with the mockup's team, to hold next to
/// docs/roadmap/mockups/04-register-and-join-team.html (left phone). The
/// switch shows the form and the form locked with the invite card under it.
class RegisterTeamPreview extends StatefulWidget {
  const RegisterTeamPreview({super.key});

  @override
  State<RegisterTeamPreview> createState() => _RegisterTeamPreviewState();
}

class _RegisterTeamPreviewState extends State<RegisterTeamPreview> {
  final _name = TextEditingController(text: 'Vulpile');
  final _phone = TextEditingController(text: '0722 123 456');
  int _size = 4;
  bool _rules = true;
  bool _data = false;
  bool _photo = true;
  int _state = 0;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _say(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(what)));
  }

  @override
  Widget build(BuildContext context) {
    final registered = _state == 1;

    return Scaffold(
      body: Column(
        children: [
          ScreenBar(
            leadingIcon: TablerIcons.x,
            onLeading: () => Navigator.maybePop(context),
            title: 'Înscrie echipa',
            subtitle: 'Moștenirea Cartografului · 14 noiembrie',
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.sm,
                        AppSpacing.page,
                        0,
                      ),
                      child: SegmentedSwitch(
                        labels: const ['Formular', 'După înscriere'],
                        selectedIndex: _state,
                        onSelected: (i) => setState(() => _state = i),
                      ),
                    ),
                    RegisterForm(
                      nameController: _name,
                      phoneController: _phone,
                      onNameChanged: (_) {},
                      onPhoneChanged: (_) {},
                      nameStatus: FieldStatus.ok,
                      nameStatusText: 'Numele e liber',
                      sizeMin: 2,
                      sizeMax: 6,
                      size: _size,
                      onSizeChanged: (n) => setState(() => _size = n),
                      rulesAccepted: _rules,
                      onRulesChanged: (v) => setState(() => _rules = v),
                      dataAccepted: _data,
                      onDataChanged: (v) => setState(() => _data = v),
                      photoConsent: _photo,
                      onPhotoChanged: (v) => setState(() => _photo = v),
                      onSubmit: () => _say('înscrie echipa'),
                      locked: registered,
                    ),
                    if (registered)
                      InviteResultSection(
                        code: 'VLP-482',
                        size: _size,
                        initials: const ['VC'],
                        onShare: () => _say('WhatsApp'),
                        onCopy: () => _say('copiază'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
