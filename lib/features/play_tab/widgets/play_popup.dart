import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamxperience/features/play_tab/controller/play_popup_controller.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/ui/ui.dart';

import 'card_deck_intro.dart';
import 'measure_size.dart';
import 'play_popup_actions.dart';
import 'play_popup_card.dart';

/// The Joacă pop-up of mockup 10, shown over the pages and under the bar.
///
/// It dims the page, then brings its card in: out of the key with a small
/// bounce when the player has a game, or as "Draw a card" (three cards fan
/// out, shuffle, the middle one flips) when it suggests one. It closes by
/// shrinking back into the key. With reduced motion it only fades.
class PlayPopup extends StatefulWidget {
  const PlayPopup({super.key, required this.controller, required this.actions});

  final PlayPopupController controller;
  final PlayPopupActions actions;

  @override
  State<PlayPopup> createState() => _PlayPopupState();
}

class _PlayPopupState extends State<PlayPopup> with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(vsync: this);
  late final AnimationController _exit = AnimationController(vsync: this);
  late final AnimationController _flipOut =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
  late final AnimationController _flipIn =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 300), value: 1);
  late final AnimationController _dragBack =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

  bool _started = false;
  bool _reduced = false;
  bool _deck = false;
  bool _deckRunning = false;
  double _cardHeight = 0;
  bool _stagger = false;
  int _generation = 0;
  int _rolls = 0;
  bool _exiting = false;
  double _drag = 0;
  double _dragFrom = 0;

  static const _bounce = Cubic(.2, .9, .3, 1);

  static final _keyScale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: .1, end: 1.03), weight: 75),
    TweenSequenceItem(tween: Tween(begin: 1.03, end: 1), weight: 25),
  ]);
  static final _keyRise = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 50, end: -6), weight: 75),
    TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 25),
  ]);

  PlayPopupController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_changed);
    _dragBack.addListener(() => setState(() => _drag = _dragFrom * (1 - Curves.easeOut.transform(_dragBack.value))));
    HapticFeedback.lightImpact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduced = MediaQuery.disableAnimationsOf(context);
    _deck = !_reduced && _c.state is PlayNone && _c.suggestions.isNotEmpty;
    _deckRunning = _deck;
    _stagger = !_reduced && !_deck;
    _entry.duration = Duration(milliseconds: _reduced ? 200 : 560);
    _exit.duration = Duration(milliseconds: _reduced ? 200 : 220);
    _entry.forward();
  }

  void _changed() {
    if (!mounted) return;
    if (_c.isClosing && !_exiting) {
      _exiting = true;
      _exit.forward().whenComplete(() {
        if (mounted) _c.closed();
      });
    }
    setState(() {});
  }

  void _deckDone() {
    if (!mounted) return;
    setState(() {
      _deckRunning = false;
      _stagger = true;
      _generation++;
    });
    _flipIn.forward(from: 0);
  }

  Future<void> _reroll() async {
    HapticFeedback.lightImpact();
    setState(() {
      _rolls++;
      _stagger = false;
    });
    if (_reduced) {
      _c.reroll();
      return;
    }
    await _flipOut.forward(from: 0);
    if (!mounted) return;
    _c.reroll();
    _flipOut.value = 0;
    await _flipIn.forward(from: 0);
  }

  /// Closes at once, without the exit, before a button navigates away.
  void _go(VoidCallback action) {
    _c.closed();
    action();
  }

  PlayPopupActions get _actions {
    final a = widget.actions;
    return PlayPopupActions(
      openEvent: (e) => _go(() => a.openEvent(e)),
      openTeam: (e) => _go(() => a.openTeam(e)),
      enterCode: (e) => _go(() => a.enterCode(e)),
      continueGame: (e, t) => _go(() => a.continueGame(e, t)),
      openChat: (e, t) => _go(() => a.openChat(e, t)),
      browseAll: () => _go(a.browseAll),
    );
  }

  void _dragUpdate(DragUpdateDetails d) {
    if (_exiting) return;
    _dragBack.stop();
    setState(() => _drag = max(0, _drag + d.delta.dy));
  }

  void _dragEnd(DragEndDetails _) {
    if (_exiting) return;
    if (_drag > 90) {
      _c.requestClose();
    } else {
      _dragFrom = _drag;
      _dragBack.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.removeListener(_changed);
    _entry.dispose();
    _exit.dispose();
    _flipOut.dispose();
    _flipIn.dispose();
    _dragBack.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _exit, _flipOut, _flipIn]),
      builder: (context, _) {
        final e = _entry.value;
        final x = Curves.easeIn.transform(_exit.value);
        final scrim = _exiting ? 1 - _exit.value : (_reduced ? e : const Interval(0, .45).transform(e));

        // Card: scale, rise and opacity around the key (60 px under the card).
        var scale = 1.0;
        var rise = _drag;
        var opacity = 1.0;
        if (_reduced) {
          opacity = _exiting ? 1 - _exit.value : e;
        } else if (_exiting) {
          scale = 1 - .9 * x;
          rise = _drag + 50 * x;
          opacity = 1 - x;
        } else if (!_deck) {
          final b = _bounce.transform(e);
          scale = _keyScale.transform(b);
          rise = _keyRise.transform(b) + _drag;
          opacity = const Interval(0, .4).transform(e);
        }
        final turnY = _flipOut.value > 0 ? _flipOut.value * pi / 2 : -(1 - _flipIn.value) * pi / 2;

        final card = KeyedSubtree(
          key: ValueKey(_generation),
          child: PlayPopupCard(
            controller: _c,
            actions: _actions,
            stagger: _stagger,
            rolls: _rolls,
            onReroll: _reroll,
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _c.requestClose,
              child: Opacity(
                opacity: scrim.clamp(0.0, 1.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: ColoredBox(color: colors.scrim),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              top: 20,
              bottom: 20,
              child: LayoutBuilder(
                builder: (context, box) => Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      IgnorePointer(
                        ignoring: _deckRunning || _exiting,
                        child: Opacity(
                          opacity: _deckRunning ? 0 : opacity.clamp(0.0, 1.0),
                          child: Transform(
                            alignment: Alignment.bottomCenter,
                            origin: const Offset(0, 60),
                            transform: Matrix4.identity()
                              ..translateByDouble(0, rise, 0, 1)
                              ..scaleByDouble(scale, scale, 1, 1),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, .001)
                                ..rotateY(turnY),
                              child: GestureDetector(
                                onVerticalDragUpdate: _dragUpdate,
                                onVerticalDragEnd: _dragEnd,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: box.maxHeight),
                                  child: SingleChildScrollView(
                                    child: MeasureSize(
                                      onChange: (size) {
                                        if (mounted && size.height != _cardHeight) {
                                          setState(() => _cardHeight = size.height);
                                        }
                                      },
                                      child: card,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_deckRunning && _cardHeight > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: CardDeckIntro(height: min(_cardHeight, box.maxHeight), onDone: _deckDone),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
