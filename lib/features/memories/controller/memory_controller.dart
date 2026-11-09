import 'package:flutter/foundation.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/team.dart';

/// The memory page: reads the game's photos and the team's name from the team.
class MemoryController extends ChangeNotifier {
  MemoryController({required this.memory, required Future<Team?> Function(String eventId) findTeam}) : _findTeam = findTeam;

  final Memory memory;
  final Future<Team?> Function(String eventId) _findTeam;

  bool _loading = true;
  List<AlbumPhoto> _album = const [];
  String? _teamName;
  bool _disposed = false;

  bool get loading => _loading;
  List<AlbumPhoto> get album => _album;

  /// Null when the team could not be read.
  String? get teamName => _teamName;

  Future<void> load() async {
    final album = await memoryAlbum(memory, (eventId) async {
      final team = await _findTeam(eventId);
      _teamName = team?.name;
      return team;
    });
    if (_disposed) return;
    _album = album;
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
