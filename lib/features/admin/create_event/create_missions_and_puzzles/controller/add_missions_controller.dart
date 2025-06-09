import 'dart:io';
import 'dart:ui';

import 'package:teamxperience/backend/repo/event_repo.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_mission/mission_widget.dart';
import 'package:teamxperience/model/mission.dart';

import '../../../../../enums/component-type.dart';
import '../../../../../model/event.dart';

class AddMissionsController {
  ImageRepo imageRepo = ImageRepo();
  EventRepo eventRepo = EventRepo();

  int selectedMission = 0;

  List<MissionWidget> missionWidgets = [];
  List<bool> isMissionDone = [];
  final VoidCallback? onStateChanged;

  late Event event;
  late String mode;


  AddMissionsController(this.event, this.mode, {this.onStateChanged}){
    buildMissionWidgets(event.nrMissions, mode);
  }


  void addNewMission() {
      event.nrMissions += 1; // Increment the count

      Mission missionAdded = Mission(id: event.missions.length.toString());
      event.addMission(missionAdded);
      isMissionDone.add(false);

      addMissionWidget(missionAdded, "create");

  }

  void addMissionWidget(Mission missionAdded, String missionMode){
    missionWidgets.add(MissionWidget(
      currentMission: missionAdded,
      mode: missionMode,
      addMissionsController: this,
      missionDone: (bool isDone) {
        int missionIndex = int.parse(missionAdded.id);
        isMissionDone[missionIndex] = isDone;
        print (isMissionDone[missionIndex]) ;
        onStateChanged?.call();
      },
    ));
  }


  void buildMissionWidgets(int nrMissions, String mode) {
      for (int i = 0; i < nrMissions; i ++){
          addMissionWidget(event.missions[i], mode);
          bool missionComplete = _isMissionComplete(event.missions[i]);
          isMissionDone.add(false);

      }
  }
  bool _isMissionComplete(Mission mission) {
    // If mission has no puzzles, it's not complete
    if (mission.puzzles.isEmpty) {
      return false;
    }

    // Check if all puzzles have a type set
    for (var puzzle in mission.puzzles) {
      if (puzzle.type == null) {
        return false;
      }
    }

    return true;
  }
  Future<void> saveEvent() async {
    try {
      // Upload main event images only if they exist and are local files
      String? backgroundURL;
      String? landingImage;

      if (event.taskBackgroundImageUrl != null &&
          event.taskBackgroundImageUrl!.isNotEmpty &&
          !event.taskBackgroundImageUrl!.startsWith('http')) {

        File backgroundFile = File(event.taskBackgroundImageUrl!);
        if (await backgroundFile.exists()) {
          backgroundURL = await imageRepo.uploadImage(backgroundFile, event.eventId, "background");
          if (backgroundURL != null) {
            event.taskBackgroundImageUrl = backgroundURL;
          }
        } else {
          print('Background image file does not exist: ${event.taskBackgroundImageUrl}');
        }
      }

      if (event.landingImageUrl != null &&
          event.landingImageUrl!.isNotEmpty &&
          !event.landingImageUrl!.startsWith('http')) {

        File landingFile = File(event.landingImageUrl!);
        if (await landingFile.exists()) {
          landingImage = await imageRepo.uploadImage(landingFile, event.eventId, "landingImage");
          if (landingImage != null) {
            event.landingImageUrl = landingImage;
          }
        } else {
          print('Landing image file does not exist: ${event.landingImageUrl}');
        }
      }

      // Process missions and their puzzles for image components
      for (int missionIndex = 0; missionIndex < event.missions.length; missionIndex++) {
        final mission = event.missions[missionIndex];

        for (int puzzleIndex = 0; puzzleIndex < mission.puzzles.length; puzzleIndex++) {
          final puzzle = mission.puzzles[puzzleIndex];

          for (int componentIndex = 0; componentIndex < puzzle.components.length; componentIndex++) {
            final component = puzzle.components[componentIndex];

            // Check if this is an image component with a local file path
            if (component.type == ComponentType.image &&
                component.imageUrl != null &&
                component.imageUrl!.isNotEmpty &&
                !component.imageUrl!.startsWith('http')) {

              try {
                File imageFile = File(component.imageUrl!);

                // Check if file exists before attempting upload
                if (await imageFile.exists()) {
                  // Create a unique identifier for this image
                  String imageIdentifier = "mission_${missionIndex}_puzzle_${puzzleIndex}_component_$componentIndex";

                  // Upload the image
                  String? uploadedUrl = await imageRepo.uploadImage(
                      imageFile,
                      event.eventId,
                      imageIdentifier
                  );

                  // Update the component with the uploaded URL
                  if (uploadedUrl != null) {
                    puzzle.components[componentIndex].imageUrl = uploadedUrl;
                    print('Successfully uploaded image: $uploadedUrl');
                  } else {
                    print('Failed to upload image for component at mission $missionIndex, puzzle $puzzleIndex, component $componentIndex');
                  }
                } else {
                  print('Image file does not exist: ${component.imageUrl}');
                  // Optionally set imageUrl to null or a placeholder
                  // puzzle.components![componentIndex].imageUrl = null;
                }

              } catch (e) {
                print('Error uploading image for component at mission $missionIndex, puzzle $puzzleIndex, component $componentIndex: $e');
                // Continue processing other images instead of stopping
              }
            }
          }
                }
            }

      // Save the event to the database after all image processing is complete
      await eventRepo.createEvent(event);
      print('Event saved successfully');

    } catch (e) {
      print('Error in saveEvent: $e');
      rethrow; // Re-throw to let calling code handle the error
    }
  }


}
