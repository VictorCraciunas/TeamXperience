import 'package:teamxperience/features/finish/logic/finish_recap.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/team.dart';

/// One picture of a team's game; [label] says when it was taken.
class AlbumPhoto {
  const AlbumPhoto(this.url, {this.label});

  final String url;
  final String? label;
}

/// The team's pictures in the order of the game: start, approved puzzle
/// photos by mission, final.
List<AlbumPhoto> teamAlbum(Team team) {
  final start = team.startPhotoUrl;
  final finish = team.finishPhotoUrl;
  return [
    if (start != null) AlbumPhoto(start, label: 'Start'),
    for (final photo in approvedPuzzlePhotos(team)) AlbumPhoto(photo.url, label: 'Misiunea ${photo.mission + 1}'),
    if (finish != null) AlbumPhoto(finish, label: 'Final'),
  ];
}

/// A memory's pictures, read from the team so a photo taken after the event
/// ended still shows. When the team has none or cannot be read, the pictures
/// the memory stored.
Future<List<AlbumPhoto>> memoryAlbum(Memory memory, Future<Team?> Function(String eventId) findTeam) async {
  Team? team;
  try {
    team = await findTeam(memory.eventId);
  } catch (_) {
    team = null;
  }
  final album = team == null ? const <AlbumPhoto>[] : teamAlbum(team);
  if (album.isNotEmpty) return album;
  return [for (final url in memory.photoUrls) AlbumPhoto(url)];
}

/// The picture standing for a memory: its first photo, else the event's main
/// picture, else none.
String? memoryThumbnail(List<AlbumPhoto> album, String? eventPicture) {
  if (album.isNotEmpty) return album.first.url;
  return eventPicture == null || eventPicture.isEmpty ? null : eventPicture;
}
