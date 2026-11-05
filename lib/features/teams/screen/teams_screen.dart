import 'package:flutter/material.dart';
import 'package:teamxperience/features/teams/controller/teams_controller.dart';
import 'package:teamxperience/features/teams/widgets/teams_view.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  TeamsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= TeamsController(context: context);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const Scaffold();

    return Scaffold(
      backgroundColor: context.colors.page,
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return TeamsView(
            crews: controller.crews ?? const [],
            myUid: controller.myUid,
            loading: controller.loading,
            failed: controller.error != null,
            onRetry: controller.retry,
            onNewCrew: controller.openNewCrew,
            onJoin: controller.openJoin,
            onShare: controller.share,
            onCopy: controller.copy,
          );
        },
      ),
    );
  }
}
