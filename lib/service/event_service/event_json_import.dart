import 'dart:convert';

import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/enums/loop_effect.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/utils/event_fonts.dart';
import 'package:teamxperience/utils/event_formats.dart';

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
    screenAnimation: reader.option('screenAnimation', ScreenAnimation.values) ?? ScreenAnimation.fade,
    animationDuration: reader.whole('animationDuration', min: 200, max: 1500),
    animationDelay: reader.whole('animationDelay', min: 0, max: 600),
    dateEvent: reader.date('dateEvent'),
    dateStartEnrollment: reader.date('dateStartEnrollment'),
    dateDeadlineEnrollment: reader.date('dateDeadlineEnrollment'),
    area: reader.text('area'),
    finishPoint: reader.text('finishPoint'),
    routeLengthKm: reader.decimal('routeLengthKm', min: 0.1, max: 100),
    durationMinutes: reader.whole('durationMinutes', min: 1),
    difficulty: reader.option('difficulty', Difficulty.values),
    teamSizeMin: reader.whole('teamSizeMin', min: 1, max: 20) ?? 2,
    teamSizeMax: reader.whole('teamSizeMax', min: 1, max: 20) ?? 6,
    maxTeams: reader.whole('maxTeams', min: 1, max: 500),
    startLatitude: reader.decimal('startLatitude', min: -90, max: 90),
    startLongitude: reader.decimal('startLongitude', min: -180, max: 180),
    finishLatitude: reader.decimal('finishLatitude', min: -90, max: 90),
    finishLongitude: reader.decimal('finishLongitude', min: -180, max: 180),
    meetingPointNote: reader.text('meetingPointNote'),
    arriveMinutesBefore: reader.whole('arriveMinutesBefore', min: 0, max: 120) ?? 15,
    whatToBring: reader.texts('whatToBring'),
    story: reader.text('story'),
    organiserName: reader.text('organiserName'),
    introLetter: reader.text('introLetter'),
    introSignature: reader.text('introSignature'),
    finishTitle: reader.text('finishTitle'),
    finishMessage: reader.text('finishMessage'),
    hintsPerMission: reader.whole('hintsPerMission', min: 0, max: 5) ?? 1,
    enterWindowMinutes: reader.whole('enterWindowMinutes', min: 1) ?? 60,
  );

  final missions = reader.list('missions');
  for (var i = 0; i < missions.length; i++) {
    final where = 'Misiunea ${i + 1}';
    final mission = _object(missions[i], where, errors);
    event.addMission(_readMission(mission, i, where, errors));
  }
  event.nrMissions = event.missions.length;

  // Cards and home still read the text fields, so the numbers win there too.
  final km = event.routeLengthKm;
  final minutes = event.durationMinutes;
  final level = event.difficulty;
  if (km != null) event.lungimeTraseu = formatKm(km);
  if (minutes != null) event.durata = formatDuration(minutes);
  if (level != null) event.dificultate = difficultyLabel(level);
  return event;
}

Mission _readMission(Map<String, dynamic> map, int index, String where, List<String> errors) {
  final reader = _Reader(map, where, errors);
  final mission = Mission(
    id: index.toString(),
    title: reader.text('title'),
    teaser: reader.text('teaser'),
    isTeaserPublic: reader.flag('isTeaserPublic') ?? false,
    latitude: reader.decimal('latitude', min: -90, max: 90),
    longitude: reader.decimal('longitude', min: -180, max: 180),
  );

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
    maxAttempts: reader.whole('maxAttempts', min: 1, max: 20),
    wrongAnswerMessage: reader.text('wrongAnswerMessage'),
    radiusMeters: reader.whole('radiusMeters', min: 10, max: 200) ?? Puzzle.defaultRadius,
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
    buttonColor: reader.color('buttonColor'),
    buttonColorOnTap: reader.color('buttonColorOnTap'),
    buttonTextColor: reader.color('buttonTextColor'),
    buttonTextColorOnTap: reader.color('buttonTextColorOnTap'),
    borderColor: reader.color('borderColor'),
    textColor: reader.color('textColor'),
    animation: reader.option('animation', AnimationType.values),
    fontSize: reader.decimal('fontSize', min: 8, max: 72),
    fontWeight: reader.choice('fontWeight', _fontWeights),
    fontFamily: reader.choice('fontFamily', eventFontNames),
    codeLength: reader.whole('codeLength', min: 1, max: 10),
    cornerRadius: reader.decimal('cornerRadius', min: 0, max: 50),
    enableFlicker: reader.flag('enableFlicker'),
    enableGlow: reader.flag('enableGlow'),
    glowColor: reader.color('glowColor'),
    inputType: reader.choice('inputType', _inputTypes),
    capsLock: reader.choice('capsLock', _capsLocks),
    frameCornerRadius: reader.decimal('frameCornerRadius', min: 0, max: 50),
    inputCornerRadius: reader.decimal('inputCornerRadius', min: 0, max: 50),
    frameBackgroundColor: reader.color('frameBackgroundColor'),
    inputBackgroundColor: reader.color('inputBackgroundColor'),
    colorBorderInput: reader.color('colorBorderInput'),
    colorBorderContainer: reader.color('colorBorderContainer'),
    // The box width only exists on a code input and the height on an image;
    // on the other kinds they are not used, so they are not checked.
    width: type == ComponentType.code ? reader.decimal('width', min: 0, max: 200) : reader.decimal('width'),
    height: type == ComponentType.image ? reader.decimal('height', min: 150, max: 500) : reader.decimal('height'),
    typewriterSpeed: reader.whole('typewriterSpeed', min: 10, max: 300),
    spaceBelow: reader.decimal('spaceBelow', min: 0, max: 120),
    letterSpacing: reader.decimal('letterSpacing', min: 0, max: 12),
    paddingY: reader.decimal('paddingY', min: 0, max: 30),
    boxHeight: reader.decimal('boxHeight', min: 20, max: 100),
    boldText: reader.flag('boldText'),
    glowOn: reader.choice('glowOn', _glowPlaces),
    lineHeight: reader.decimal('lineHeight', min: 0.8, max: 2),
    italic: reader.flag('italic'),
    uppercase: reader.flag('uppercase'),
    shadowColor: reader.color('shadowColor'),
    shadowBlur: reader.decimal('shadowBlur', min: 0, max: 30),
    shadowDistance: reader.decimal('shadowDistance', min: 0, max: 20),
    opacity: reader.decimal('opacity', min: 0, max: 1),
    borderWidth: reader.decimal('borderWidth', min: 0, max: 6),
    loopEffect: reader.option('loopEffect', LoopEffect.values),
    answerFeedback: reader.flag('answerFeedback'),
    textAlign: reader.choice('textAlign', _textAligns),
  );
}

/// What the editors of the app offer. Anything else would not show up in the
/// component editor, or would not draw at all.
const _fontWeights = ['Thin (100)', 'Light (300)', 'Regular (400)', 'Medium (500)', 'Bold (700)', 'Black (900)'];
const _textAligns = ['left', 'center', 'right', 'justify'];
const _inputTypes = ['Separated', 'Free'];
const _capsLocks = ['CapsLock', 'Fără'];
const _glowPlaces = ['frame', 'boxes'];

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

  double? decimal(String key, {double? min, double? max}) {
    final value = map[key];
    if (value == null) return null;
    if (value is! num) {
      _fail(key, 'trebuie să fie un număr.');
      return null;
    }
    if (!_inRange(value, min, max)) {
      _fail(key, 'trebuie să fie între ${_show(min)} și ${_show(max)}.');
      return null;
    }
    return value.toDouble();
  }

  int? whole(String key, {int? min, int? max}) {
    final value = map[key];
    if (value == null) return null;
    if (value is! num || value != value.roundToDouble()) {
      _fail(
        key,
        min == null
            ? 'trebuie să fie un număr întreg.'
            : max == null
            ? 'trebuie să fie un număr întreg de cel puțin $min.'
            : 'trebuie să fie un număr întreg între $min și $max.',
      );
      return null;
    }
    if (!_inRange(value, min, max)) {
      _fail(key, max == null ? 'trebuie să fie cel puțin ${_show(min)}.' : 'trebuie să fie între ${_show(min)} și ${_show(max)}.');
      return null;
    }
    return value.toInt();
  }

  bool _inRange(num value, num? min, num? max) {
    if (min != null && value < min) return false;
    if (max != null && value > max) return false;
    return true;
  }

  String _show(num? limit) => limit == null ? '…' : limit.toString().replaceAll(RegExp(r'\.0$'), '');

  /// One of [allowed], written exactly like that.
  String? choice(String key, List<String> allowed) {
    final value = text(key);
    if (value == null) return null;
    if (allowed.contains(value)) return value;
    _fail(key, 'nu poate fi „$value”. Valori posibile: ${allowed.join(', ')}.');
    return null;
  }

  /// A colour written as 6 hex digits, with or without the #.
  String? color(String key) {
    final value = text(key);
    if (value == null) return null;
    if (RegExp(r'^#?[0-9A-Fa-f]{6}$').hasMatch(value)) return value;
    _fail(key, 'nu este o culoare. Scrie-o cu 6 cifre hex, de exemplu #33FF66.');
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

  /// A list of texts; anything else in it is a mistake.
  List<String> texts(String key) {
    final items = list(key);
    if (items.any((item) => item is! String)) {
      _fail(key, 'trebuie să fie o listă de texte ["...", "..."].');
      return const [];
    }
    return [for (final item in items) (item as String).trim()].where((t) => t.isNotEmpty).toList();
  }

  List<dynamic> list(String key) {
    final value = map[key];
    if (value == null) return const [];
    if (value is List) return value;
    _fail(key, 'trebuie să fie o listă [ ... ].');
    return const [];
  }
}
