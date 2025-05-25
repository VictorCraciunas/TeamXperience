import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/missions_service.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/mission_widget.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/mission.dart';

import '../../../../../enums/animation_type.dart';
import '../../../../../enums/puzzle_type.dart';
import '../../../../../model/event.dart';

class AddMissionsController {
  final MissionsService _addMissionsService = MissionsService();

  int selectedMission = 0;

  List<MissionWidget> missionWidgets = [];

  Event? event;

  List<Mission> initializeMissions() {
    return _addMissionsService.initializeMissions(event!.nrMissions);
  }
  void addNewMission() {
    if (event != null) {
      event!.nrMissions += 1; // Increment the count
      _addMissionsService.addMission(); // Append a new mission
      missionWidgets.add(MissionWidget(
        nrMission: missionWidgets.length,
        onSetPuzzles: (nrPuzzles) {
          _addMissionsService.initializePuzzleAtMission(nrPuzzles, missionWidgets.length - 1);
        },
        addMissionsController: this,
      ));
    }
  }

  Component getComponent(int nrMission, int nrPuzzle, int indexComponent){
    return _addMissionsService.missions[nrMission].puzzles[nrPuzzle].components[indexComponent];
  }

  void addPuzzleAtMission(int missionIndex) {
    _addMissionsService.addPuzzleAtMission(missionIndex);
  }

  List<MissionWidget> buildMissionWidgets() {
    if (event == null) return [];
    return List.generate(
      event!.nrMissions,
      (missionSelected) => MissionWidget(
        nrMission: missionSelected,
        onSetPuzzles: (nrPuzzles) {
          _addMissionsService.initializePuzzleAtMission(
            nrPuzzles,
            missionSelected,
          );
        },
        addMissionsController: this,
      ),
    );
  }

  Component addComponent(
    int missionSelected,
    int puzzleSelected,
    ComponentType type, {
    String? text,
    String? textColor,
    AnimationType? animation,
    String? imageUrl,
    String? buttonLabel,
    String? buttonColor, // New
    String? buttonColorOnTap, // New
    String? buttonTextColor, // New
    String? buttonTextColorOnTap, // New
    String? borderColor,
    double? fontSize,
    String? fontWeight,
    String? fontFamily,
    int? codeLength,
    double? cornerRadius, // New
    bool? enableFlicker, // New
    bool? enableGlow, // New
    String? glowColor, // New
    String? inputType,
    String? capsLock,
    double? frameCornerRadius,
    double? inputCornerRadius,
    String? frameBackgroundColor,
    String? inputBackgroundColor,
    String? colorBorderInput,
    String? colorBorderContainer,
    double? width,
    double? height,
  }) {
    final component = _addMissionsService.addComponentAtPuzzleAtMission(
      missionSelected,
      puzzleSelected,
      type,
      text: text,
      textColor: textColor,
      animation: animation,
      imageUrl: imageUrl,
      buttonLabel: buttonLabel,
      buttonColor: buttonColor,
      buttonColorOnTap: buttonColorOnTap,
      buttonTextColor: buttonTextColor,
      buttonTextColorOnTap: buttonTextColorOnTap,
      borderColor: borderColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      codeLength: codeLength,
      cornerRadius: cornerRadius,
      // New
      enableFlicker: enableFlicker,
      // New
      enableGlow: enableGlow,
      // New
      glowColor: glowColor,
      // New
      inputType: inputType,
      capsLock: capsLock,
      frameCornerRadius: frameCornerRadius,
      inputCornerRadius: inputCornerRadius,
      frameBackgroundColor: frameBackgroundColor,
      inputBackgroundColor: inputBackgroundColor,
      colorBorderInput: colorBorderInput,
      colorBorderContainer: colorBorderContainer,
      width: width,
      height: height,
    );
    return component;
  }

  void deleteAllComponents(int missionSelected, int puzzleSelected) {
    _addMissionsService.deleteAllComponentsAtPuzzleAtMission(
      missionSelected,
      puzzleSelected,
    );
  }

  void setPuzzleType(
    int missionSelected,
    int puzzleSelected,
    PuzzleType type,
    String? code,
    String? coordinates,
    String? indiciu,
  ) {
    _addMissionsService.setPuzzleTypeAtPuzzleAtMission(
      missionSelected,
      puzzleSelected,
      type,
      code,
      coordinates,
      indiciu
    );
  }

  void printMissions() {
    _addMissionsService.printMissions();
  }

  void deleteComponent(
    int missionSelected,
    int puzzleSelected,
    int componentIndex,
  ) {
    _addMissionsService.deleteComponentAtPuzzleAtMission(
      missionSelected,
      puzzleSelected,
      componentIndex,
    );
  }

  void saveEvent() {
    _addMissionsService.saveEvent(event!);
  }
}
