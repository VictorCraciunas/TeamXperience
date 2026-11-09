import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:teamxperience/ui/ui.dart';

/// The start-up screen: "TeamXperience" animated on the app navy. The intro
/// plays once (letters rise, the yellow X lands, the route draws), then the
/// part marked "loop" (the pulsing dot) repeats until the app moves on.
/// Made by `tool/make_splash_lottie.py` from the Poppins Bold outlines.
class BrandSplash extends StatefulWidget {
  const BrandSplash({super.key});

  static const asset = 'assets/loader/teamxperience.json';

  @override
  State<BrandSplash> createState() => _BrandSplashState();
}

class _BrandSplashState extends State<BrandSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loaded(LottieComposition composition) {
    final loopStart = composition.getMarker('loop')?.start ?? 0;
    _controller.duration = composition.duration;
    if (MediaQuery.disableAnimationsOf(context)) {
      // Reduced motion: the finished logo, still.
      _controller.value = loopStart;
      return;
    }
    _controller.forward().whenComplete(() {
      if (mounted) _controller.repeat(min: loopStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const ValueKey('brand-splash'),
      color: context.colors.navy,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Semantics(
            label: 'TeamXperience',
            child: Lottie.asset(BrandSplash.asset, controller: _controller, onLoaded: _loaded),
          ),
        ),
      ),
    );
  }
}
