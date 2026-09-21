import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';

/// Shown while the session is restored from secure storage.
///
/// The OS draws the native splash first — same colour and mark — and this
/// takes over the instant Flutter starts, so the two are indistinguishable.
/// System bars stay hidden for both, and are restored when the router moves
/// on.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.indigoSurface,
      body: Center(child: AppLogo(size: 140)),
    );
  }
}
