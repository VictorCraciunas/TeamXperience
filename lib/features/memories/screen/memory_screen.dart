import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/chat/widgets/full_screen_image.dart';
import 'package:teamxperience/features/memories/controller/memory_controller.dart';
import 'package:teamxperience/features/memories/widgets/memory_album_view.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

/// One past game and its photos. The route takes `{'memory': Memory}`.
class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  MemoryController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    final memory = args is Map ? args['memory'] : null;
    if (memory is! Memory) return;
    final uid = context.read<UserProvider>().currentUser?.uid;
    _controller = MemoryController(
      memory: memory,
      findTeam: (eventId) async => uid == null ? null : TeamService().getUserTeamForEvent(eventId, uid),
    )..load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Event? _loadedEvent(String eventId) {
    for (final event in context.read<EventList>().events) {
      if (event.eventId == eventId) return event;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = _controller;
    return Scaffold(
      backgroundColor: colors.page,
      appBar: const MyAppBar(appBarText: 'Amintire'),
      body: controller == null
          ? const SizedBox.shrink()
          : ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                if (controller.loading) return const Center(child: CircularProgressIndicator());
                final event = _loadedEvent(controller.memory.eventId);
                return SingleChildScrollView(
                  child: MemoryAlbumView(
                    memory: controller.memory,
                    album: controller.album,
                    teamName: controller.teamName,
                    eventPicture: event?.landingImageUrl,
                    onEvent: event == null
                        ? null
                        : () => Navigator.pushNamed(
                              context,
                              Routes.eventDetails,
                              arguments: {'event': event, 'isAdmin': false},
                            ),
                    onPhoto: (photo) => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => FullScreenImage(imageUrl: photo.url)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
