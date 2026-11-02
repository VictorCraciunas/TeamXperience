import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
import 'package:teamxperience/service/event_service/event_json_import.dart';
import 'package:teamxperience/utils/event_fonts.dart';

Map<String, dynamic> _event({
  Map<String, dynamic>? extra,
  List<dynamic>? missions,
}) => {
  'name': 'Treasure Hunt Sibiu',
  'type': 'PUBLIC',
  'dateEvent': '2026-11-20T18:00:00',
  'missions': missions ??
      [
        {
          'puzzles': [
            {
              'type': 'code',
              'code': 'SIBIU',
              'components': [
                {'type': 'text', 'text': 'Salut', 'fontSize': 18},
              ],
            },
          ],
        },
      ],
  ...?extra,
};

EventImportResult _import(Object? json) => importEventFromJson(jsonEncode(json));

void main() {
  group('a good event', () {
    test('is read into an event', () {
      final result = _import(_event(extra: {'location': 'Sibiu', 'startCode': 'GO'}));
      expect(result.errors, isEmpty);
      final event = result.event;
      expect(event, isNotNull);
      expect(event?.name, 'Treasure Hunt Sibiu');
      expect(event?.location, 'Sibiu');
      expect(event?.type, EventType.PUBLIC);
      expect(event?.startCode, 'GO');
    });

    test('dates written as text become dates', () {
      final event = _import(
        _event(extra: {
          'dateStartEnrollment': '2026-11-01T09:00',
          'dateDeadlineEnrollment': '2026-11-19T23:59:00',
        }),
      ).event;
      expect(event?.dateEvent, DateTime(2026, 11, 20, 18));
      expect(event?.dateStartEnrollment, DateTime(2026, 11, 1, 9));
      expect(event?.dateDeadlineEnrollment, DateTime(2026, 11, 19, 23, 59));
    });

    test('missions and puzzles are numbered by their place, whatever the file says', () {
      final event = _import(
        _event(missions: [
          {'id': '9', 'puzzles': [{'id': '7', 'type': 'code', 'components': []}, {'type': 'code', 'components': []}]},
          {'puzzles': []},
        ]),
      ).event;
      expect(event?.missions.map((m) => m.id), ['0', '1']);
      expect(event?.missions.first.puzzles.map((p) => p.id), ['0', '1']);
      expect(event?.nrMissions, 2);
    });

    test('whole numbers are accepted where a decimal is expected', () {
      final event = _import(
        _event(missions: [
          {
            'puzzles': [
              {
                'type': 'geolocation',
                'latitude': 45,
                'longitude': 24,
                'components': [
                  {'type': 'text', 'text': 'x', 'fontSize': 18, 'cornerRadius': 8, 'width': 200, 'height': 40},
                  {'type': 'code', 'codeLength': 4, 'frameCornerRadius': 12, 'inputCornerRadius': 6},
                ],
              },
            ],
          },
        ]),
      ).event;
      final puzzle = event?.missions.single.puzzles.single;
      expect(puzzle?.latitude, 45.0);
      expect(puzzle?.components.first.fontSize, 18.0);
      expect(puzzle?.components.first.width, 200.0);
      expect(puzzle?.components.last.codeLength, 4);
      expect(puzzle?.components.last.frameCornerRadius, 12.0);
    });

    test('puzzle and component types are read', () {
      final puzzle = _import(_event()).event?.missions.single.puzzles.single;
      expect(puzzle?.type, PuzzleType.code);
      expect(puzzle?.components.single.type, ComponentType.text);
    });

    test('what the file says about id, status and being stopped is ignored', () {
      final event = _import(_event(extra: {'eventId': 'abc', 'status': 'published', 'isStopped': true})).event;
      expect(event?.eventId, '');
      expect(event?.isStopped, isFalse);
      expect(event?.isDraft, isFalse, reason: 'saving it as a draft sets the status');
    });

    test('keys it does not know are ignored', () {
      expect(_import(_event(extra: {'something': 1})).errors, isEmpty);
    });

    test('an event with nothing but a name can be imported, to be finished in the app', () {
      final result = _import({'name': 'Doar un nume'});
      expect(result.errors, isEmpty);
      expect(result.event?.missions, isEmpty);
    });
  });

  group('the sample in docs', () {
    final eventJsonSample = File('docs/event-import-sample.json').readAsStringSync();

    test('imports without errors', () {
      final result = importEventFromJson(eventJsonSample);
      expect(result.errors, isEmpty);
    });

    test('is a complete event that could be published', () {
      final event = importEventFromJson(eventJsonSample).event;
      expect(event, isNotNull);
      if (event != null) {
        expect(publishProblems(event).map((p) => p.text), isEmpty);
      }
    });

    test('shows each puzzle type', () {
      final event = importEventFromJson(eventJsonSample).event;
      final types = event?.missions.expand((m) => m.puzzles).map((p) => p.type).toSet();
      expect(types, containsAll([PuzzleType.code, PuzzleType.geolocation, PuzzleType.imageToUpload]));
    });
  });

  group('mistakes are explained', () {
    test('text that is not JSON', () {
      final result = importEventFromJson('{ nu e json');
      expect(result.event, isNull);
      expect(result.errors.single, contains('JSON'));
    });

    test('empty text', () {
      expect(importEventFromJson('   ').errors, isNotEmpty);
    });

    test('JSON that is not an object', () {
      expect(_import([1, 2]).errors.single, contains('obiect'));
    });

    test('an unknown event type lists the ones that exist', () {
      final result = _import(_event(extra: {'type': 'SECRET'}));
      expect(result.event, isNull);
      expect(result.errors.single, allOf(contains('type'), contains('SECRET'), contains('PUBLIC'), contains('PRIVAT')));
    });

    test('an unknown puzzle type says where it is', () {
      final result = _import(
        _event(missions: [
          {'puzzles': [{'type': 'code', 'components': []}, {'type': 'quiz', 'components': []}]},
        ]),
      );
      expect(result.errors.single, allOf(contains('Misiunea 1'), contains('puzzle 2'), contains('quiz')));
    });

    test('an unknown component type says where it is', () {
      final result = _import(
        _event(missions: [
          {'puzzles': [{'type': 'code', 'components': [{'type': 'text'}, {'type': 'video'}]}]},
        ]),
      );
      expect(result.errors.single, allOf(contains('Misiunea 1'), contains('puzzle 1'), contains('componenta 2'), contains('video')));
    });

    test('a component without a type', () {
      final result = _import(
        _event(missions: [
          {'puzzles': [{'type': 'code', 'components': [{'text': 'fără tip'}]}]},
        ]),
      );
      expect(result.errors.single, allOf(contains('componenta 1'), contains('type')));
    });

    test('a date that is not a date', () {
      final result = _import(_event(extra: {'dateEvent': 'mâine seara'}));
      expect(result.errors.single, allOf(contains('dateEvent'), contains('2026-')));
    });

    test('a field with the wrong kind of value', () {
      final result = _import(_event(extra: {'name': 5}));
      expect(result.errors.single, contains('name'));
    });

    test('missions that are not a list', () {
      expect(_import(_event(extra: {'missions': 'două'})).errors.single, contains('missions'));
    });

    test('a number where text is expected inside a component', () {
      final result = _import(
        _event(missions: [
          {'puzzles': [{'type': 'code', 'components': [{'type': 'text', 'text': 12}]}]},
        ]),
      );
      expect(result.errors.single, contains('componenta 1'));
    });

    test('several mistakes are all reported, not only the first', () {
      final result = _import(
        _event(extra: {'type': 'SECRET', 'dateEvent': 'nu'}),
      );
      expect(result.errors.length, 2);
    });

    test('a file with mistakes gives no event', () {
      expect(_import(_event(extra: {'type': 'SECRET'})).event, isNull);
    });
  });

  group('the animation of the screen', () {
    test('fade and none are accepted', () {
      expect(_import(_event(extra: {'screenAnimation': 'fade'})).event?.screenAnimation, ScreenAnimation.fade);
      expect(_import(_event(extra: {'screenAnimation': 'none'})).event?.screenAnimation, ScreenAnimation.none);
    });

    test('left out it fades, as the app always did', () {
      expect(_import(_event()).event?.screenAnimation, ScreenAnimation.fade);
    });

    test('every kind of entrance is accepted', () {
      for (final name in ['fade', 'none', 'slideFromLeft', 'slideFromRight', 'slideFromBottom', 'slideFromTop', 'zoom', 'bounce']) {
        final result = _import(_event(extra: {'screenAnimation': name}));
        expect(result.errors, isEmpty, reason: name);
        expect(result.event?.screenAnimation.name, name);
      }
    });

    test('the duration is 200 to 1500 and the delay 0 to 600, whole milliseconds', () {
      expect(_import(_event(extra: {'animationDuration': 200, 'animationDelay': 0})).errors, isEmpty);
      expect(_import(_event(extra: {'animationDuration': 1500, 'animationDelay': 600})).errors, isEmpty);
      expect(_import(_event(extra: {'animationDuration': 199})).errors.single, contains('animationDuration'));
      expect(_import(_event(extra: {'animationDuration': 1501})).errors.single, contains('animationDuration'));
      expect(_import(_event(extra: {'animationDelay': -1})).errors.single, contains('animationDelay'));
      expect(_import(_event(extra: {'animationDelay': 601})).errors.single, contains('animationDelay'));
      expect(_import(_event(extra: {'animationDelay': 100.5})).errors.single, contains('animationDelay'));
    });

    test('the timing is read onto the event', () {
      final event = _import(_event(extra: {'screenAnimation': 'bounce', 'animationDuration': 700, 'animationDelay': 150})).event;
      expect(event?.animationDuration, 700);
      expect(event?.animationDelay, 150);
    });

    test('left out, the timing is automatic', () {
      final event = _import(_event()).event;
      expect(event?.animationDuration, isNull);
      expect(event?.animationDelay, isNull);
    });

    test('anything else is refused and the mistake lists what exists', () {
      final result = _import(_event(extra: {'screenAnimation': 'spin'}));
      expect(result.event, isNull);
      expect(result.errors.single, allOf(contains('screenAnimation'), contains('spin'), contains('fade'), contains('none'), contains('bounce')));
    });
  });

  group('values the app could not draw are refused', () {
    EventImportResult withComponent(Map<String, dynamic> component) => _import(
      _event(missions: [
        {
          'puzzles': [
            {
              'type': 'code',
              'components': [component],
            },
          ],
        },
      ]),
    );

    void expectRefused(Map<String, dynamic> component, String key) {
      final result = withComponent(component);
      expect(result.event, isNull, reason: '$component');
      expect(result.errors.single, allOf(contains(key), contains('Misiunea 1'), contains('componenta 1')));
    }

    void expectAccepted(Map<String, dynamic> component) {
      final result = withComponent(component);
      expect(result.errors, isEmpty, reason: '$component');
    }

    test('a colour that is not a hex colour', () {
      expectRefused({'type': 'text', 'textColor': 'red'}, 'textColor');
      expectRefused({'type': 'button', 'buttonColor': '#12345'}, 'buttonColor');
      expectRefused({'type': 'code', 'colorBorderInput': 'verde'}, 'colorBorderInput');
      expectRefused({'type': 'button', 'glowColor': '#GGGGGG'}, 'glowColor');
    });

    test('hex colours with or without the #', () {
      expectAccepted({'type': 'text', 'textColor': '#33FF66'});
      expectAccepted({'type': 'text', 'textColor': '33ff66'});
    });

    test('a font weight that is not one of the six', () {
      expectRefused({'type': 'text', 'fontWeight': 'bold'}, 'fontWeight');
      expectRefused({'type': 'button', 'fontWeight': 'Bold'}, 'fontWeight');
      for (final weight in ['Thin (100)', 'Light (300)', 'Regular (400)', 'Medium (500)', 'Bold (700)', 'Black (900)']) {
        expectAccepted({'type': 'text', 'fontWeight': weight});
      }
    });

    test('a font that is not one of the app', () {
      expectRefused({'type': 'text', 'fontFamily': 'Arial'}, 'fontFamily');
      expectRefused({'type': 'text', 'fontFamily': 'orbitron'}, 'fontFamily');
      expectRefused({'type': 'text', 'fontFamily': 'ShareTechMono'}, 'fontFamily');
    });

    test('every font of the app is accepted on text, buttons and code inputs', () {
      for (final font in eventFontNames) {
        for (final type in ['text', 'button', 'code']) {
          expectAccepted({'type': type, 'fontFamily': font});
        }
      }
    });

    test('the mistake for a font lists all of them', () {
      final message = withComponent({'type': 'text', 'fontFamily': 'Arial'}).errors.single;
      for (final font in eventFontNames) {
        expect(message, contains(font));
      }
    });

    test('text alignment', () {
      expectRefused({'type': 'text', 'textAlign': 'middle'}, 'textAlign');
      for (final align in ['left', 'center', 'right', 'justify']) {
        expectAccepted({'type': 'text', 'textAlign': align});
      }
    });

    test('the code input choices', () {
      expectRefused({'type': 'code', 'inputType': 'Mixed'}, 'inputType');
      expectRefused({'type': 'code', 'capsLock': 'yes'}, 'capsLock');
      expectAccepted({'type': 'code', 'inputType': 'Separated', 'capsLock': 'CapsLock'});
      expectAccepted({'type': 'code', 'inputType': 'Free', 'capsLock': 'Fără'});
    });

    test('text size from 8 to 72', () {
      expectRefused({'type': 'text', 'fontSize': 7}, 'fontSize');
      expectRefused({'type': 'button', 'fontSize': 73}, 'fontSize');
      expectAccepted({'type': 'text', 'fontSize': 8});
      expectAccepted({'type': 'code', 'fontSize': 72});
    });

    test('number of characters from 1 to 10, a whole number', () {
      expectRefused({'type': 'code', 'codeLength': 0}, 'codeLength');
      expectRefused({'type': 'code', 'codeLength': 11}, 'codeLength');
      expectRefused({'type': 'code', 'codeLength': 4.5}, 'codeLength');
      expectAccepted({'type': 'code', 'codeLength': 1});
      expectAccepted({'type': 'code', 'codeLength': 10});
    });

    test('typewriter speed from 10 to 300', () {
      expectRefused({'type': 'text', 'typewriterSpeed': 5}, 'typewriterSpeed');
      expectRefused({'type': 'text', 'typewriterSpeed': 301}, 'typewriterSpeed');
      expectAccepted({'type': 'text', 'typewriterSpeed': 10});
      expectAccepted({'type': 'text', 'typewriterSpeed': 300});
    });

    test('corner radius from 0 to 50 on every component that has one', () {
      expectRefused({'type': 'button', 'cornerRadius': 51}, 'cornerRadius');
      expectRefused({'type': 'image', 'cornerRadius': -1}, 'cornerRadius');
      expectRefused({'type': 'code', 'frameCornerRadius': 60}, 'frameCornerRadius');
      expectRefused({'type': 'code', 'inputCornerRadius': 60}, 'inputCornerRadius');
      expectAccepted({'type': 'button', 'cornerRadius': 0});
      expectAccepted({'type': 'image', 'cornerRadius': 50});
    });

    test('box width from 0 to 200 on a code input, image height from 150 to 500', () {
      expectRefused({'type': 'code', 'width': 201}, 'width');
      expectRefused({'type': 'image', 'height': 149}, 'height');
      expectRefused({'type': 'image', 'height': 501}, 'height');
      expectAccepted({'type': 'code', 'width': 200});
      expectAccepted({'type': 'image', 'height': 500});
    });

    test('space below from 0 to 120, on every kind of component', () {
      for (final type in ['text', 'image', 'button', 'code']) {
        expectAccepted({'type': type, 'spaceBelow': 0});
        expectAccepted({'type': type, 'spaceBelow': 120});
        expectAccepted({'type': type, 'spaceBelow': 12.5});
        expectRefused({'type': type, 'spaceBelow': -1}, 'spaceBelow');
        expectRefused({'type': type, 'spaceBelow': 121}, 'spaceBelow');
        expectRefused({'type': type, 'spaceBelow': 'mult'}, 'spaceBelow');
      }
    });

    test('space below is read onto the component', () {
      final event = _import(
        _event(missions: [
          {
            'puzzles': [
              {
                'type': 'code',
                'components': [
                  {'type': 'text', 'spaceBelow': 8},
                  {'type': 'button'},
                ],
              },
            ],
          },
        ]),
      ).event;
      final components = event?.missions.single.puzzles.single.components;
      expect(components?.first.spaceBelow, 8.0);
      expect(components?.last.spaceBelow, isNull);
    });

    test('letter spacing from 0 to 12 and space above and below from 0 to 30 on a button', () {
      expectRefused({'type': 'button', 'letterSpacing': -1}, 'letterSpacing');
      expectRefused({'type': 'button', 'letterSpacing': 13}, 'letterSpacing');
      expectRefused({'type': 'button', 'paddingY': -1}, 'paddingY');
      expectRefused({'type': 'button', 'paddingY': 31}, 'paddingY');
      for (final value in [0, 6.5, 12]) {
        expectAccepted({'type': 'button', 'letterSpacing': value});
      }
      for (final value in [0, 15, 30]) {
        expectAccepted({'type': 'button', 'paddingY': value});
      }
    });

    test('box height from 20 to 100 on a code input', () {
      expectRefused({'type': 'code', 'boxHeight': 19}, 'boxHeight');
      expectRefused({'type': 'code', 'boxHeight': 101}, 'boxHeight');
      expectAccepted({'type': 'code', 'boxHeight': 20});
      expectAccepted({'type': 'code', 'boxHeight': 100});
    });

    test('bold text is true or false', () {
      expectAccepted({'type': 'code', 'boldText': true});
      expectAccepted({'type': 'code', 'boldText': false});
      expectRefused({'type': 'code', 'boldText': 'da'}, 'boldText');
    });

    test('the glow of a code input is on the frame or on the boxes', () {
      expectAccepted({'type': 'code', 'glowOn': 'frame'});
      expectAccepted({'type': 'code', 'glowOn': 'boxes'});
      expectRefused({'type': 'code', 'glowOn': 'all'}, 'glowOn');
      final message = withComponent({'type': 'code', 'glowOn': 'all'}).errors.single;
      expect(message, allOf(contains('frame'), contains('boxes')));
    });

    test('the new options are read onto the component', () {
      final component = withComponent({
        'type': 'code',
        'boxHeight': 60,
        'boldText': false,
        'glowOn': 'boxes',
        'letterSpacing': 3,
        'paddingY': 12,
      }).event?.missions.single.puzzles.single.components.single;
      expect(component?.boxHeight, 60.0);
      expect(component?.boldText, isFalse);
      expect(component?.glowOn, 'boxes');
      expect(component?.letterSpacing, 3.0);
      expect(component?.paddingY, 12.0);
    });

    test('line height from 0.8 to 2, on a text', () {
      expectRefused({'type': 'text', 'lineHeight': 0.7}, 'lineHeight');
      expectRefused({'type': 'text', 'lineHeight': 2.1}, 'lineHeight');
      expectAccepted({'type': 'text', 'lineHeight': 0.8});
      expectAccepted({'type': 'text', 'lineHeight': 2});
      expectAccepted({'type': 'text', 'lineHeight': 1.5});
    });

    test('italic and capitals are true or false', () {
      for (final key in ['italic', 'uppercase']) {
        expectAccepted({'type': 'text', key: true});
        expectAccepted({'type': 'text', key: false});
        expectRefused({'type': 'text', key: 'da'}, key);
      }
    });

    test('the shadow of a text: blur 0 to 30, distance 0 to 20, a colour', () {
      expectRefused({'type': 'text', 'shadowBlur': -1}, 'shadowBlur');
      expectRefused({'type': 'text', 'shadowBlur': 31}, 'shadowBlur');
      expectRefused({'type': 'text', 'shadowDistance': -1}, 'shadowDistance');
      expectRefused({'type': 'text', 'shadowDistance': 21}, 'shadowDistance');
      expectRefused({'type': 'text', 'shadowColor': 'negru'}, 'shadowColor');
      expectAccepted({'type': 'text', 'shadowBlur': 0, 'shadowDistance': 0, 'shadowColor': '#000000'});
      expectAccepted({'type': 'text', 'shadowBlur': 30, 'shadowDistance': 20});
    });

    test('the text effects are read onto the component', () {
      final component = withComponent({
        'type': 'text',
        'text': 'x',
        'lineHeight': 1.5,
        'italic': true,
        'uppercase': true,
        'shadowColor': '#112233',
        'shadowBlur': 6,
        'shadowDistance': 4,
        'enableGlow': true,
        'glowColor': '#33FF66',
      }).event?.missions.single.puzzles.single.components.single;
      expect(component?.lineHeight, 1.5);
      expect(component?.italic, isTrue);
      expect(component?.uppercase, isTrue);
      expect(component?.shadowColor, '#112233');
      expect(component?.shadowBlur, 6.0);
      expect(component?.shadowDistance, 4.0);
      expect(component?.enableGlow, isTrue);
    });

    test('opacity from 0 to 1 on every kind of component', () {
      for (final type in ['text', 'image', 'button', 'code']) {
        expectAccepted({'type': type, 'opacity': 0});
        expectAccepted({'type': type, 'opacity': 0.5});
        expectAccepted({'type': type, 'opacity': 1});
        expectRefused({'type': type, 'opacity': -0.1}, 'opacity');
        expectRefused({'type': type, 'opacity': 1.1}, 'opacity');
        expectRefused({'type': type, 'opacity': 'jumătate'}, 'opacity');
      }
    });

    test('border width from 0 to 6', () {
      expectAccepted({'type': 'image', 'borderWidth': 0});
      expectAccepted({'type': 'button', 'borderWidth': 6});
      expectAccepted({'type': 'image', 'borderWidth': 1.5});
      expectRefused({'type': 'image', 'borderWidth': -1}, 'borderWidth');
      expectRefused({'type': 'button', 'borderWidth': 7}, 'borderWidth');
    });

    test('the box effects are read onto the component', () {
      final component = withComponent({
        'type': 'image',
        'opacity': 0.8,
        'borderWidth': 2,
        'borderColor': '#33FF66',
        'shadowBlur': 6,
        'shadowDistance': 3,
        'enableGlow': true,
        'glowColor': '#FF3EA5',
      }).event?.missions.single.puzzles.single.components.single;
      expect(component?.opacity, 0.8);
      expect(component?.borderWidth, 2.0);
      expect(component?.borderColor, '#33FF66');
      expect(component?.shadowBlur, 6.0);
    });

    test('a loop effect is one of the five, on every kind of component', () {
      for (final type in ['text', 'image', 'button', 'code']) {
        for (final name in ['pulse', 'float', 'shake', 'flicker', 'glitch']) {
          expectAccepted({'type': type, 'loopEffect': name});
        }
      }
    });

    test('any other loop effect is refused and the mistake lists the five', () {
      expectRefused({'type': 'text', 'loopEffect': 'spin'}, 'loopEffect');
      expectRefused({'type': 'text', 'loopEffect': 'none'}, 'loopEffect');
      final message = withComponent({'type': 'text', 'loopEffect': 'spin'}).errors.single;
      for (final name in ['pulse', 'float', 'shake', 'flicker', 'glitch']) {
        expect(message, contains(name));
      }
    });

    test('the loop effect is read onto the component', () {
      final component = withComponent({'type': 'button', 'loopEffect': 'pulse'}).event?.missions.single.puzzles.single.components.single;
      expect(component?.loopEffect?.name, 'pulse');
    });

    test('the text animations are none, typewriter and decode', () {
      for (final name in ['none', 'typewriter', 'decode']) {
        expectAccepted({'type': 'text', 'animation': name});
      }
      expectRefused({'type': 'text', 'animation': 'wave'}, 'animation');
      final message = withComponent({'type': 'text', 'animation': 'wave'}).errors.single;
      expect(message, allOf(contains('none'), contains('typewriter'), contains('decode')));
    });

    test('the answer feedback of a code input is true or false', () {
      expectAccepted({'type': 'code', 'answerFeedback': true});
      expectAccepted({'type': 'code', 'answerFeedback': false});
      expectRefused({'type': 'code', 'answerFeedback': 'nu'}, 'answerFeedback');
      final component = withComponent({'type': 'code', 'answerFeedback': false}).event?.missions.single.puzzles.single.components.single;
      expect(component?.answerFeedback, isFalse);
    });

    test('options a component does not use are not checked', () {
      expectAccepted({'type': 'text', 'width': 999, 'height': 999});
    });

    test('the mistake says what is allowed', () {
      final result = withComponent({'type': 'text', 'fontSize': 500});
      expect(result.errors.single, allOf(contains('8'), contains('72')));
      final weight = withComponent({'type': 'text', 'fontWeight': 'bold'});
      expect(weight.errors.single, contains('Bold (700)'));
    });
  });
}
