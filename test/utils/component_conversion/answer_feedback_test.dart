import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/answer_feedback.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../ui/pump_ui.dart';

Component _code({bool? feedback, String inputType = 'Separated'}) => Component(
      type: ComponentType.code,
      codeLength: 4,
      inputType: inputType,
      fontSize: 20,
      answerFeedback: feedback,
    );

Future<void> _draw(WidgetTester tester, Component component, AnswerFeedback? feedback) {
  return pumpUi(
    tester,
    Column(children: [ComponentToWidget().convert(component, feedback: feedback)]),
    width: 360,
  );
}

Finder get _input => find.byType(TextField).first;

Offset _place(WidgetTester tester) => tester.getTopLeft(_input);

void main() {
  group('the notifier', () {
    test('has no answer at first', () {
      expect(AnswerFeedback().last, isNull);
    });

    test('says a wrong answer and tells those who listen', () {
      final feedback = AnswerFeedback();
      var told = 0;
      feedback.addListener(() => told++);
      feedback.wrong();
      expect(feedback.last, AnswerResult.wrong);
      expect(told, 1);
    });

    test('says a right answer', () {
      final feedback = AnswerFeedback()..correct();
      expect(feedback.last, AnswerResult.correct);
    });

    test('tells every time, even for the same answer again', () {
      final feedback = AnswerFeedback();
      var told = 0;
      feedback.addListener(() => told++);
      feedback
        ..wrong()
        ..wrong()
        ..wrong();
      expect(told, 3);
    });

    test('counts the answers, so a repeated one can be told apart', () {
      final feedback = AnswerFeedback();
      expect(feedback.count, 0);
      feedback
        ..wrong()
        ..wrong();
      expect(feedback.count, 2);
    });
  });

  group('how it looks', () {
    test('every kind ends as it started: in place, full size, no tint', () {
      for (final result in AnswerResult.values) {
        final end = answerFrame(result, 1);
        expect(end.dx, 0, reason: result.name);
        expect(end.scale, 1, reason: result.name);
        expect(end.flash, 0, reason: result.name);
        final start = answerFrame(result, 0);
        expect(start.dx, 0, reason: result.name);
        expect(start.scale, 1, reason: result.name);
        expect(start.flash, 0, reason: result.name);
      }
    });

    test('a wrong answer shakes left and right and flashes red', () {
      final frames = [for (var t = 0.0; t <= 1.0; t += 0.02) answerFrame(AnswerResult.wrong, t)];
      expect(frames.any((f) => f.dx < -4), isTrue);
      expect(frames.any((f) => f.dx > 4), isTrue);
      expect(frames.every((f) => f.dx.abs() <= 10), isTrue);
      expect(frames.any((f) => f.flash > 0.5), isTrue);
      expect(frames.every((f) => f.scale == 1), isTrue);
      expect(answerFrameColor(AnswerResult.wrong).r, greaterThan(0.8));
      expect(answerFrameColor(AnswerResult.wrong).g, lessThan(0.5));
    });

    test('the shake dies down', () {
      final early = answerFrame(AnswerResult.wrong, 0.2).dx.abs();
      final late = [for (var t = 0.85; t <= 1.0; t += 0.01) answerFrame(AnswerResult.wrong, t).dx.abs()].reduce((a, b) => a > b ? a : b);
      expect(late, lessThan(early + 0.001));
      expect(late, lessThan(3));
    });

    test('a right answer pops and flashes green, without shaking', () {
      final frames = [for (var t = 0.0; t <= 1.0; t += 0.02) answerFrame(AnswerResult.correct, t)];
      expect(frames.every((f) => f.dx == 0), isTrue);
      expect(frames.any((f) => f.scale > 1.05), isTrue);
      expect(frames.every((f) => f.scale <= 1.2), isTrue);
      expect(frames.any((f) => f.flash > 0.5), isTrue);
      expect(answerFrameColor(AnswerResult.correct).g, greaterThan(0.8));
      expect(answerFrameColor(AnswerResult.correct).r, lessThan(0.5));
    });

    test('the flash stays between 0 and 1', () {
      for (final result in AnswerResult.values) {
        for (var t = -0.5; t <= 1.5; t += 0.05) {
          expect(answerFrame(result, t).flash, inInclusiveRange(0, 1), reason: '${result.name} $t');
        }
      }
    });

    test('how long each lasts', () {
      expect(answerDuration(AnswerResult.wrong).inMilliseconds, inInclusiveRange(400, 1000));
      expect(answerDuration(AnswerResult.correct).inMilliseconds, inInclusiveRange(400, 1000));
    });
  });

  group('on a code input', () {
    testWidgets('a wrong answer moves the input sideways and then it is back in place', (tester) async {
      final feedback = AnswerFeedback();
      await _draw(tester, _code(), feedback);
      final start = _place(tester);

      feedback.wrong();
      var moved = false;
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 25));
        if ((_place(tester).dx - start.dx).abs() > 3) moved = true;
      }
      expect(moved, isTrue);

      await tester.pump(const Duration(seconds: 2));
      expect(_place(tester), start);
    });

    testWidgets('and it flashes red while it does', (tester) async {
      final feedback = AnswerFeedback();
      await _draw(tester, _code(), feedback);
      expect(find.byType(ColorFiltered), findsNothing);

      feedback.wrong();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.byType(ColorFiltered), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(ColorFiltered), findsNothing);
    });

    testWidgets('a right answer pops the input, and no more shaking', (tester) async {
      final feedback = AnswerFeedback();
      await _draw(tester, _code(), feedback);
      final start = _place(tester);
      final width = tester.getRect(_input).width;

      feedback.correct();
      var biggest = width;
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 25));
        expect(_place(tester).dy, closeTo(start.dy, 8), reason: 'no shaking, only growing about the middle');
        final now = tester.getRect(_input).width;
        if (now > biggest) biggest = now;
      }
      expect(biggest, greaterThan(width));

      await tester.pump(const Duration(seconds: 2));
      expect(tester.getRect(_input).width, closeTo(width, 0.01));
    });

    testWidgets('the layout does not change, only the drawing', (tester) async {
      final feedback = AnswerFeedback();
      await _draw(tester, _code(), feedback);
      final size = tester.getSize(find.byType(IntrinsicWidth));
      feedback.wrong();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getSize(find.byType(IntrinsicWidth)), size);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('a single free box does the same', (tester) async {
      final feedback = AnswerFeedback();
      await _draw(tester, _code(inputType: 'Free'), feedback);
      final start = _place(tester);
      feedback.wrong();
      var moved = false;
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 25));
        if ((_place(tester).dx - start.dx).abs() > 3) moved = true;
      }
      expect(moved, isTrue);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('a second wrong answer shakes again', (tester) async {
      final feedback = AnswerFeedback();
      await _draw(tester, _code(), feedback);
      final start = _place(tester);
      feedback.wrong();
      await tester.pump(const Duration(seconds: 2));
      feedback.wrong();
      var moved = false;
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 25));
        if ((_place(tester).dx - start.dx).abs() > 3) moved = true;
      }
      expect(moved, isTrue);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('switched off on the component, nothing happens', (tester) async {
      final feedback = AnswerFeedback();
      await _draw(tester, _code(feedback: false), feedback);
      final start = _place(tester);
      feedback.wrong();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_place(tester), start);
      expect(find.byType(ColorFiltered), findsNothing);
    });

    testWidgets('without a notifier there is nothing to react to', (tester) async {
      await _draw(tester, _code(), null);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with animations switched off in the phone settings nothing moves', (tester) async {
      final feedback = AnswerFeedback();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(body: Column(children: [ComponentToWidget().convert(_code(), feedback: feedback)])),
          ),
        ),
      );
      final start = _place(tester);
      feedback.wrong();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_place(tester), start);
    });

    testWidgets('the typing still works while and after it shakes', (tester) async {
      final feedback = AnswerFeedback();
      String typed = '';
      await pumpUi(
        tester,
        Column(children: [ComponentToWidget().convert(_code(), feedback: feedback, onTextChanged: (v) => typed = v)]),
        width: 360,
      );
      feedback.wrong();
      await tester.pump(const Duration(seconds: 2));
      await tester.enterText(find.byType(TextField).first, 'a');
      expect(typed, 'a');
    });

    testWidgets('leaving the screen while it shakes is fine', (tester) async {
      final feedback = AnswerFeedback();
      await _draw(tester, _code(), feedback);
      feedback.wrong();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(const SizedBox());
      feedback.wrong();
      expect(tester.takeException(), isNull);
    });
  });
}
