import 'package:flutter/widgets.dart';

/// Runs [refresh] once the game screen is shown and again when it closes, so
/// the player's active game (and the bar's "În joc") follows the game starting
/// and ending. Both calls wait until after the frame, so a refresh that
/// notifies listeners never lands in the middle of a build.
class RefreshesActiveGame extends StatefulWidget {
  const RefreshesActiveGame({super.key, required this.refresh, required this.child});

  final Future<void> Function() refresh;
  final Widget child;

  @override
  State<RefreshesActiveGame> createState() => _RefreshesActiveGameState();
}

class _RefreshesActiveGameState extends State<RefreshesActiveGame> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.refresh());
  }

  @override
  void dispose() {
    final refresh = widget.refresh;
    WidgetsBinding.instance.addPostFrameCallback((_) => refresh());
    WidgetsBinding.instance.scheduleFrame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
