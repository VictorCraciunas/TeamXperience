import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/admin/create_event/start/create_event_start.dart';
import 'package:teamxperience/features/admin/create_event/start/import_errors_card.dart';
import 'package:teamxperience/features/admin/create_event/start/import_event_controller.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Import din JSON": paste an event written outside the app. It is saved as a
/// draft and opened in the event form to be checked and published.
class ImportEventPage extends StatefulWidget {
  const ImportEventPage({super.key});

  @override
  State<ImportEventPage> createState() => _ImportEventPageState();
}

class _ImportEventPageState extends State<ImportEventPage> {
  late final ImportEventController _controller;

  @override
  void initState() {
    super.initState();
    final eventList = context.read<EventList>();
    _controller = ImportEventController(
      saveDraft: (event) => eventList.saveDraft(event, wizardStep: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final navigator = Navigator.of(context);
    final saved = await _controller.import();
    if (saved == null || !mounted) return;

    navigator.pushReplacementNamed(
      Routes.createEvent,
      arguments: StartFromDraft(saved).arguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: 'Import din JSON'),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder:
              (context, _) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.page, 16, AppSpacing.page, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lipește JSON-ul evenimentului. Se salvează ca ciornă, pe care o verifici și o publici din aplicație.',
                      style: TextStyle(color: context.colors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Lipește',
                            variant: AppButtonVariant.secondary,
                            foregroundColor: context.colors.text,
                            onPressed: _controller.paste,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            label: 'Copiază un model',
                            variant: AppButtonVariant.secondary,
                            foregroundColor: context.colors.text,
                            onPressed: _controller.copySample,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _controller.textController,
                      hint: '{ ... }',
                      maxLines: 12,
                    ),
                    if (_controller.errors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ImportErrorsCard(errors: _controller.errors),
                    ],
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Importă ca ciornă',
                      onPressed: _controller.busy ? null : _import,
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
