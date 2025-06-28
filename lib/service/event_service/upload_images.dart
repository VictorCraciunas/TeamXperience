import 'dart:io';

import '../../backend/storage/storage_images.dart';
import '../../enums/component-type.dart';
import '../../model/event.dart';

class UploadImagesHelper{
  final ImageRepo _imageRepo = ImageRepo();

  // Helper methods
  Future<Event> uploadEventImages(Event event) async {
    // Upload landing image if it's a local file
    if (event.landingImageUrl != null &&
        !isNetworkUrl(event.landingImageUrl!)) {
      final file = File(event.landingImageUrl!);
      if (await file.exists()) {
        final url = await _imageRepo.uploadImage(file, event.eventId, "landingImage");
        if (url != null) event.landingImageUrl = url;
      }
    }

    // Upload background image if it's a local file
    if (event.taskBackgroundImageUrl != null &&
        !isNetworkUrl(event.taskBackgroundImageUrl!)) {
      final file = File(event.taskBackgroundImageUrl!);
      if (await file.exists()) {
        final url = await _imageRepo.uploadImage(file, event.eventId, "background");
        if (url != null) event.taskBackgroundImageUrl = url;
      }
    }

    // Upload component images
    await uploadComponentImages(event);

    return event;
  }

  Future<void> uploadComponentImages(Event event) async {
    for (int missionIndex = 0; missionIndex < event.missions.length; missionIndex++) {
      final mission = event.missions[missionIndex];
      for (int puzzleIndex = 0; puzzleIndex < mission.puzzles.length; puzzleIndex++) {
        final puzzle = mission.puzzles[puzzleIndex];
        for (int componentIndex = 0; componentIndex < puzzle.components.length; componentIndex++) {
          final component = puzzle.components[componentIndex];

          if (component.type == ComponentType.image &&
              component.imageUrl != null &&
              !isNetworkUrl(component.imageUrl!)) {

            final file = File(component.imageUrl!);
            if (await file.exists()) {
              final identifier = "mission_${missionIndex}_puzzle_${puzzleIndex}_component_$componentIndex";
              final url = await _imageRepo.uploadImage(file, event.eventId, identifier);
              if (url != null) component.imageUrl = url;
            }
          }
        }
      }
    }
  }

  bool isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
}