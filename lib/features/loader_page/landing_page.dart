import 'dart:async';

import 'package:flutter/material.dart';
import 'logic/intro_gate.dart';
import 'widgets/brand_splash.dart';

import '../../utils/auth_util.dart';

class LandingPage extends StatefulWidget {
  final AuthUtil authUtil;

  const LandingPage({required this.authUtil, super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  /// Done once the logo's intro has played: the X landed, the route drawn.
  final _intro = Completer<void>();

  @override
  void initState() {
    super.initState();
    // Call the method after the first frame is rendered to ensure context is available
    // role based redirect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authUtil.checkUserAndRedirect(context, after: introGate(_intro.future));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandSplash(onIntroDone: () {
        if (!_intro.isCompleted) _intro.complete();
      }),
    );
  }
}