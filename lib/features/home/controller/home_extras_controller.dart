import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/features/home/logic/home_content.dart' as content;
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/model/team.dart';

/// What Home shows besides events: the player's newest memory with its album,
/// and their crew's place in the season. Streams and reads are passed in. A
/// failure only leaves the section empty.
class HomeExtrasController extends ChangeNotifier {
  HomeExtrasController({
    required Stream<List<Memory>> Function(String uid) memories,
    required Stream<List<Crew>> Function(String uid) crews,
    required Stream<List<SeasonStanding>> standings,
    required this.seasonName,
    required Future<Team?> Function(String eventId, String uid) findTeam,
  })  : _memories = memories,
        _crews = crews,
        _findTeam = findTeam {
    _standingsWatch = standings.listen((value) {
      _standings = value;
      _changed();
    }, onError: (Object _) {
      _standings = const [];
      _changed();
    });
  }

  final Stream<List<Memory>> Function(String uid) _memories;
  final Stream<List<Crew>> Function(String uid) _crews;
  final Future<Team?> Function(String eventId, String uid) _findTeam;

  /// The season now under way.
  final String seasonName;

  StreamSubscription<List<SeasonStanding>>? _standingsWatch;
  StreamSubscription<List<Memory>>? _memoriesWatch;
  StreamSubscription<List<Crew>>? _crewsWatch;
  String? _uid;
  bool _disposed = false;

  List<SeasonStanding> _standings = const [];
  Set<String> _crewIds = const {};
  Memory? _memory;
  List<AlbumPhoto> _album = const [];

  /// The player's newest finished game; null when none.
  Memory? get memory => _memory;

  /// That game's photos.
  List<AlbumPhoto> get album => _album;

  ({int place, SeasonStanding standing})? get seasonSpot => content.seasonSpot(_standings, _crewIds);

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  /// Follows [uid]'s memory and crews; null stops. The same uid keeps them.
  void watch(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _memoriesWatch?.cancel();
    _crewsWatch?.cancel();
    _memoriesWatch = null;
    _crewsWatch = null;
    _memory = null;
    _album = const [];
    _crewIds = const {};
    _changed();
    if (uid == null) return;
    _memoriesWatch = _memories(uid).listen((value) {
      _memory = value.isEmpty ? null : value.first;
      _changed();
      reloadAlbum();
    }, onError: (Object _) {
      _memory = null;
      _album = const [];
      _changed();
    });
    _crewsWatch = _crews(uid).listen((value) {
      _crewIds = {for (final crew in value) crew.id};
      _changed();
    }, onError: (Object _) {
      _crewIds = const {};
      _changed();
    });
  }

  /// Reads the newest memory's photos again from the team.
  Future<void> reloadAlbum() async {
    final memory = _memory;
    final uid = _uid;
    if (memory == null || uid == null) {
      _album = const [];
      _changed();
      return;
    }
    final album = await memoryAlbum(memory, (eventId) => _findTeam(eventId, uid));
    // The player or the memory may have changed during the read.
    if (_disposed || !identical(_memory, memory) || _uid != uid) return;
    _album = album;
    _changed();
  }

  @override
  void dispose() {
    _disposed = true;
    _standingsWatch?.cancel();
    _memoriesWatch?.cancel();
    _crewsWatch?.cancel();
    super.dispose();
  }
}
