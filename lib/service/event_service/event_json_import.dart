import 'dart:convert';

import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';

/// What came out of reading an event from JSON text: the event, or the list of
/// everything that was wrong with the text (never both).
class EventImportResult {
  const EventImportResult.success(Event this.event) : errors = const [];
  const EventImportResult.failure(this.errors) : event = null;

  final Event? event;
  final List<String> errors;

  bool get ok => event != null;
}

/// Reads an event from JSON text, for organisers who write the event outside
/// the app. Dates are plain text like `2026-11-20T18:00`, whole numbers are fine
/// where decimals are expected, and ids are numbered by place. Nothing is
/// required here: what is missing is found later, when the draft is checked.
EventImportResult importEventFromJson(String text) {
  if (text.trim().isEmpty) {
    return const EventImportResult.failure(['Nu ai lipit nimic.']);
  }

  Object? decoded;
  try {
    decoded = jsonDecode(text);
  } on FormatException catch (e) {
    return EventImportResult.failure(['Textul nu este JSON valid: ${e.message}']);
  }

  if (decoded is! Map<String, dynamic>) {
    return const EventImportResult.failure([
      'JSON-ul trebuie să fie un obiect, care începe cu { și se termină cu }.',
    ]);
  }

  final errors = <String>[];
  final event = _readEvent(decoded, errors);
  return errors.isEmpty ? EventImportResult.success(event) : EventImportResult.failure(errors);
}

Event _readEvent(Map<String, dynamic> map, List<String> errors) {
  final reader = _Reader(map, '', errors);

  final event = Event(
    eventId: '',
    name: reader.text('name'),
    location: reader.text('location'),
    description: reader.text('description'),
    startCode: reader.text('startCode', allowNumber: true),
    punctDeStart: reader.text('punctDeStart'),
    lungimeTraseu: reader.text('lungimeTraseu'),
    durata: reader.text('durata'),
    dificultate: reader.text('dificultate'),
    landingImageUrl: reader.text('landingImageUrl'),
    taskBackgroundImageUrl: reader.text('taskBackgroundImageUrl'),
    type: reader.option('type', EventType.values),
    dateEvent: reader.date('dateEvent'),
    dateStartEnrollment: reader.date('dateStartEnrollment'),
    dateDeadlineEnrollment: reader.date('dateDeadlineEnrollment'),
  );

  final missions = reader.list('missions');
  for (var i = 0; i < missions.length; i++) {
    final where = 'Misiunea ${i + 1}';
    final mission = _object(missions[i], where, errors);
    event.addMission(_readMission(mission, i, where, errors));
  }
  event.nrMissions = event.missions.length;
  return event;
}

Mission _readMission(Map<String, dynamic> map, int index, String where, List<String> errors) {
  final reader = _Reader(map, where, errors);
  final mission = Mission(id: index.toString());

  final puzzles = reader.list('puzzles');
  for (var i = 0; i < puzzles.length; i++) {
    final puzzleWhere = '$where, puzzle ${i + 1}';
    final puzzle = _object(puzzles[i], puzzleWhere, errors);
    mission.addPuzzle(_readPuzzle(puzzle, i, puzzleWhere, errors));
  }
  return mission;
}

Puzzle _readPuzzle(Map<String, dynamic> map, int index, String where, List<String> errors) {
  final reader = _Reader(map, where, errors);
  final puzzle = Puzzle(
    id: index.toString(),
    type: reader.option('type', PuzzleType.values),
    code: reader.text('code', allowNumber: true),
    latitude: reader.decimal('latitude'),
    longitude: reader.decimal('longitude'),
    indiciu: reader.text('indiciu'),
  );

  final components = reader.list('components');
  for (var i = 0; i < components.length; i++) {
    final componentWhere = '$where, componenta ${i + 1}';
    final component = _object(components[i], componentWhere, errors);
    puzzle.addComponent(_readComponent(component, componentWhere, errors));
  }
  return puzzle;
}

Component _readComponent(Map<String, dynamic> map, String where, List<String> errors) {
  final reader = _Reader(map, where, errors);

  final type = reader.option('type', ComponentType.values);
  if (type == null && map['type'] == null) {
    errors.add('$where: lipsește câmpul „type” (${ComponentType.values.map((e) => e.name).join(', ')}).');
  }

  return Component(
    type: type,
    text: reader.text('text'),
    imageUrl: reader.text('imageUrl'),
    buttonLabel: reader.text('buttonLabel'),
    buttonColor: reader.text('buttonColor'),
    buttonColorOnTap: reader.text('buttonColorOnTap'),
    buttonTextColor: reader.text('buttonTextColor'),
    buttonTextColorOnTap: reader.text('buttonTextColorOnTap'),
    borderColor: reader.text('borderColor'),
    textColor: reader.text('textColor'),
    animation: reader.option('animation', AnimationType.values),
    fontSize: reader.decimal('fontSize'),
    fontWeight: reader.text('fontWeight'),
    fontFamily: reader.text('fontFamily'),
    codeLength: reader.whole('codeLength'),
    cornerRadius: reader.decimal('cornerRadius'),
    enableFlicker: reader.flag('enableFlicker'),
    enableGlow: reader.flag('enableGlow'),
    glowColor: reader.text('glowColor'),
    inputType: reader.text('inputType'),
    capsLock: reader.text('capsLock'),
    frameCornerRadius: reader.decimal('frameCornerRadius'),
    inputCornerRadius: reader.decimal('inputCornerRadius'),
    frameBackgroundColor: reader.text('frameBackgroundColor'),
    inputBackgroundColor: reader.text('inputBackgroundColor'),
    colorBorderInput: reader.text('colorBorderInput'),
    colorBorderContainer: reader.text('colorBorderContainer'),
    width: reader.decimal('width'),
    height: reader.decimal('height'),
    typewriterSpeed: reader.whole('typewriterSpeed'),
    textAlign: reader.text('textAlign'),
  );
}

Map<String, dynamic> _object(Object? value, String where, List<String> errors) {
  if (value is Map<String, dynamic>) return value;
  errors.add('$where: trebuie să fie un obiect { ... }.');
  return {};
}

/// Reads typed fields out of one JSON object, noting a mistake (and carrying on)
/// when a field has the wrong kind of value.
class _Reader {
  _Reader(this.map, this.where, this.errors);

  final Map<String, dynamic> map;
  final String where;
  final List<String> errors;

  void _fail(String key, String problem) {
    final prefix = where.isEmpty ? '' : '$where: ';
    errors.add('$prefix„$key” $problem');
  }

  String? text(String key, {bool allowNumber = false}) {
    final value = map[key];
    if (value == null) return null;
    if (value is String) return value;
    if (allowNumber && value is num) return value.toString();
    _fail(key, 'trebuie să fie text.');
    return null;
  }

  double? decimal(String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    _fail(key, 'trebuie să fie un număr.');
    return null;
  }

  int? whole(String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    _fail(key, 'trebuie să fie un număr întreg.');
    return null;
  }

  bool? flag(String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is bool) return value;
    _fail(key, 'trebuie să fie true sau false.');
    return null;
  }

  DateTime? date(String key) {
    final value = map[key];
    if (value == null) return null;
    final parsed = value is String ? DateTime.tryParse(value) : null;
    if (parsed == null) {
      _fail(key, 'nu este o dată validă. Scrie-o așa: 2026-11-20T18:00');
    }
    return parsed;
  }

  T? option<T extends Enum>(String key, List<T> values) {
    final value = map[key];
    if (value == null) return null;
    for (final option in values) {
      if (option.name == value) return option;
    }
    _fail(key, 'nu poate fi „$value”. Valori posibile: ${values.map((e) => e.name).join(', ')}.');
    return null;
  }

  List<dynamic> list(String key) {
    final value = map[key];
    if (value == null) return const [];
    if (value is List) return value;
    _fail(key, 'trebuie să fie o listă [ ... ].');
    return const [];
  }
}
