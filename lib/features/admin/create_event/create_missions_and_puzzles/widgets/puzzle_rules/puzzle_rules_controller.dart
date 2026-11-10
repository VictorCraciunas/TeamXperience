import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/puzzle.dart';

/// Holds the "Reguli" form of one puzzle: the answer, the hint, how many
/// attempts players get and what they are told when they are wrong.
class PuzzleRulesController {
  PuzzleRulesController(this.puzzle) {
    answerController.text = puzzle.code ?? '';
    latitudeController.text = puzzle.latitude?.toString() ?? '';
    longitudeController.text = puzzle.longitude?.toString() ?? '';
    hintController.text = puzzle.indiciu ?? '';
    maxAttemptsController.text = puzzle.maxAttempts?.toString() ?? '';
    wrongAnswerController.text = puzzle.wrongAnswerMessage ?? '';
    radiusController.text = puzzle.radiusMeters == Puzzle.defaultRadius ? '' : '${puzzle.radiusMeters}';
  }

  final Puzzle puzzle;

  final answerController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final hintController = TextEditingController();

  /// Empty means no limit.
  final maxAttemptsController = TextEditingController();

  /// Empty means the default line.
  final wrongAnswerController = TextEditingController();

  /// Metres; empty means 20.
  final radiusController = TextEditingController();

  String? _text(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  double? _number(TextEditingController controller) {
    final value = _text(controller);
    return value == null ? null : double.tryParse(value.replaceAll(',', '.'));
  }

  String? _coordinateError(TextEditingController controller, double limit, String name) {
    if (_text(controller) == null) return null;

    final value = _number(controller);
    if (value == null) return 'Introdu un număr';
    if (value < -limit || value > limit) {
      return '$name trebuie să fie între -${limit.toInt()} și ${limit.toInt()}';
    }
    return null;
  }

  int? get _maxAttempts {
    final value = int.tryParse(maxAttemptsController.text.trim());
    return value != null && value >= 1 && value <= 20 ? value : null;
  }

  /// A limit that is not a whole number from 1 to 20.
  String? get maxAttemptsError {
    if (_text(maxAttemptsController) == null) return null;
    return _maxAttempts == null ? 'Un număr întreg între 1 și 20' : null;
  }

  int? get _radius {
    final value = int.tryParse(radiusController.text.trim());
    return value != null && value >= 10 && value <= 200 ? value : null;
  }

  /// A circle size that is not a whole number from 10 to 200.
  String? get radiusError {
    if (_text(radiusController) == null) return null;
    return _radius == null ? 'Un număr întreg între 10 și 200' : null;
  }

  /// The place in the two fields, or null when they cannot be read.
  ({double lat, double lng})? get placeInFields {
    final lat = double.tryParse(latitudeController.text.trim());
    final lng = double.tryParse(longitudeController.text.trim());
    if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) return null;
    return (lat: lat, lng: lng);
  }

  /// Fills the two fields; a puzzle's circle is small, so six decimals.
  void setPlace(({double lat, double lng}) place) {
    latitudeController.text = place.lat.toStringAsFixed(6);
    longitudeController.text = place.lng.toStringAsFixed(6);
  }

  String? get latitudeError => _coordinateError(latitudeController, 90, 'Latitudinea');
  String? get longitudeError => _coordinateError(longitudeController, 180, 'Longitudinea');

  /// True when changing the type would throw away something the organiser typed.
  bool get hasDataToLose =>
      (puzzle.code ?? '').isNotEmpty ||
      puzzle.latitude != null ||
      puzzle.longitude != null ||
      (puzzle.indiciu ?? '').isNotEmpty;

  /// Gives the puzzle another type. What belonged to the old type (answer,
  /// place) and the hint are cleared; what is on the puzzle screen is kept.
  void changeType(PuzzleType type) {
    if (puzzle.type == type) return;

    puzzle
      ..type = type
      ..code = null
      ..latitude = null
      ..longitude = null
      ..indiciu = null
      ..maxAttempts = null
      ..wrongAnswerMessage = null
      ..radiusMeters = Puzzle.defaultRadius;
    answerController.clear();
    radiusController.clear();
    maxAttemptsController.clear();
    wrongAnswerController.clear();
    latitudeController.clear();
    longitudeController.clear();
    hintController.clear();
  }

  /// Writes the form onto the puzzle.
  void apply() {
    final type = puzzle.type;

    puzzle.code = type == PuzzleType.code ? _text(answerController) : null;
    puzzle.indiciu = _text(hintController);
    puzzle.maxAttempts = type == PuzzleType.code ? _maxAttempts : null;
    puzzle.wrongAnswerMessage = type == PuzzleType.code ? _text(wrongAnswerController) : null;

    puzzle.radiusMeters = type == PuzzleType.geolocation ? (_radius ?? Puzzle.defaultRadius) : Puzzle.defaultRadius;
    if (type == PuzzleType.geolocation) {
      puzzle.latitude = latitudeError == null ? _number(latitudeController) : null;
      puzzle.longitude = longitudeError == null ? _number(longitudeController) : null;
    }
  }

  void dispose() {
    answerController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    hintController.dispose();
    maxAttemptsController.dispose();
    wrongAnswerController.dispose();
    radiusController.dispose();
  }
}
