import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/memories/controller/memories_controller.dart';
import 'package:teamxperience/features/profile/widgets/memory_card.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

/// All the player's past games, newest first. Each row shows what it already
/// holds; the photos are read when one is opened.
class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  static const int _limit = 50;

  MemoriesController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final uid = context.read<UserProvider>().currentUser?.uid;
    _controller = MemoriesController(
      stream: uid == null ? Stream.value(const <Memory>[]) : UserRepo().streamMemories(uid, limit: _limit),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String? _pictureOf(Memory memory) {
    final stored = memory.photoUrls;
    final album = stored.isEmpty ? const <AlbumPhoto>[] : [AlbumPhoto(stored.first)];
    String? picture;
    for (final event in context.read<EventList>().events) {
      if (event.eventId == memory.eventId) picture = event.landingImageUrl;
    }
    return memoryThumbnail(album, picture);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = _controller;
    return Scaffold(
      backgroundColor: colors.page,
      appBar: const MyAppBar(appBarText: 'Amintiri'),
      body: controller == null
          ? const SizedBox.shrink()
          : ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                if (controller.loading) return const Center(child: CircularProgressIndicator());
                final memories = controller.memories;
                if (memories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        controller.failed ? 'Nu am putut încărca amintirile.' : 'Aici apar jocurile tale terminate.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, height: 1.45, color: colors.muted),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: memories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => MemoryCard(
                    memory: memories[i],
                    imageUrl: _pictureOf(memories[i]),
                    onTap: () => Navigator.pushNamed(context, Routes.memory, arguments: {'memory': memories[i]}),
                  ),
                );
              },
            ),
    );
  }
}
