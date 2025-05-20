import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../utils/auth_util.dart';

class LandingPage extends StatefulWidget {
  final AuthUtil authUtil;

  const LandingPage({required this.authUtil, super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Call the method after the first frame is rendered to ensure context is available
    // role based redirect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authUtil.checkUserAndRedirect(context);
    });
  }

  // -------- loader -------------
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(child: Lottie.asset('assets/loader/loader.json', width: 700, height: 700),),
    );
  }
}