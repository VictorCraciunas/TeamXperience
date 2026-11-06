import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/trail_layout.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import 'trail_current_card.dart';
import 'trail_done_stop.dart';
import 'trail_finish_stop.dart';
import 'trail_line_painter.dart';
import 'trail_locked_stop.dart';

/// The mission route as a winding trail (mockup 06): the stops bottom to
/// top on a smooth line, solid up to the current mission and dashed after.
/// Scrolls when taller than its space, and opens on the current mission
/// (scrolled there again whenever the current mission changes).
class RouteTrailView extends StatefulWidget {
  const RouteTrailView({super.key, required this.stops, required this.onContinue});

  final List<TrailStop> stops;
  final VoidCallback onContinue;

  @override
  State<RouteTrailView> createState() => _RouteTrailViewState();
}

class _RouteTrailViewState extends State<RouteTrailView> {
  final ScrollController _scroll = ScrollController();

  /// The mission number last scrolled to.
  int? _shownCurrent;

  List<TrailStop> get stops => widget.stops;
  VoidCallback get onContinue => widget.onContinue;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Brings the stop at [point] to the middle of the view. The view is
  /// reversed, so an offset counts up from the bottom of the trail.
  void _scrollTo(Offset point, double height, double viewport) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final target = (height - point.dy) - viewport / 2;
      _scroll.jumpTo(target.clamp(0.0, _scroll.position.maxScrollExtent));
    });
  }

  /// The stops that get a place of their own: the flag rides in the locked
  /// group's row when there is one.
  List<TrailStop> get _placed => [
    for (var i = 0; i < stops.length; i++)
      if (!(stops[i] is FinishStop && i > 0 && stops[i - 1] is LockedStop)) stops[i],
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final placed = _placed;
    final current = placed.indexWhere((s) => s is CurrentStop);
    final solidUpTo = current < 0 ? placed.length - 1 : current;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final points = trailPoints(placed.length, width: width);
        final height = trailHeight(placed.length);
        if (current >= 0) {
          final stop = placed[current];
          if (stop is CurrentStop && stop.number != _shownCurrent) {
            _shownCurrent = stop.number;
            _scrollTo(points[current], height, constraints.maxHeight);
          }
        }

        Widget at(int i) {
          final stop = placed[i];
          final p = points[i];
          final onRight = p.dx > width / 2;
          return switch (stop) {
            DoneStop() =>
              onRight
                  ? Positioned(
                    right: width - p.dx - 16,
                    top: p.dy - 16,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: p.dx + 16),
                      child: TrailDoneStop(number: stop.number, label: stop.label, labelOnLeft: true),
                    ),
                  )
                  : Positioned(
                    left: p.dx - 16,
                    top: p.dy - 16,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: width - p.dx + 16),
                      child: TrailDoneStop(number: stop.number, label: stop.label),
                    ),
                  ),
            // Centred on its stop, but kept inside the trail at either end.
            CurrentStop() => Positioned(
              left: (p.dx - TrailCurrentCard.width / 2).clamp(0.0, (width - TrailCurrentCard.width).clamp(0.0, width)),
              top: i == 0 ? p.dy + 16 : (i == placed.length - 1 ? p.dy - 16 : p.dy),
              child: FractionalTranslation(
                translation: Offset(0, i == 0 ? -1 : (i == placed.length - 1 ? 0 : -.5)),
                child: TrailCurrentCard(
                  number: stop.number,
                  title: stop.title,
                  distance: stop.distance,
                  onContinue: onContinue,
                ),
              ),
            ),
            LockedStop() =>
              onRight
                  ? Positioned(
                    right: width - p.dx - 14,
                    top: p.dy - 14,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: p.dx + 14),
                      child: TrailLockedStop(label: stop.label, mirrored: true),
                    ),
                  )
                  : Positioned(
                    left: p.dx - 14,
                    top: p.dy - 14,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: width - p.dx + 14),
                      child: TrailLockedStop(label: stop.label),
                    ),
                  ),
            FinishStop() => Positioned(left: p.dx - 16, top: p.dy - 16, child: const TrailFinishStop()),
          };
        }

        return SingleChildScrollView(
          controller: _scroll,
          reverse: true,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: TrailLinePainter(points: points, solidUpTo: solidUpTo, color: palette.accent),
                  ),
                ),
                for (var i = 0; i < placed.length; i++) at(i),
              ],
            ),
          ),
        );
      },
    );
  }
}
