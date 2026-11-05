import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/play_tab/controller/play_tab_controller.dart';
import 'package:teamxperience/features/play_tab/widgets/play_tab_view.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';

/// The Joacă tab of the player shell.
class PlayTabScreen extends StatefulWidget {
  const PlayTabScreen({super.key});

  @override
  State<PlayTabScreen> createState() => _PlayTabScreenState();
}

class _PlayTabScreenState extends State<PlayTabScreen> {
  PlayTabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= PlayTabController(
      userEvents: context.read<UserEventsProvider>(),
      eventList: context.read<EventList>(),
      navigator: Navigator.of(context),
      onBrowse: () => context.read<ShellController>().select(PlayerTab.events),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    return Column(
      children: [
        const TabHeader(title: 'Joacă'),
        Expanded(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => PlayTabView(
              state: controller.state,
              onContinue: controller.continueGame,
              onEnterCode: controller.enterCode,
              onOpenEvent: controller.openEvent,
              onBrowse: controller.onBrowse,
            ),
          ),
        ),
      ],
    );
  }
}
