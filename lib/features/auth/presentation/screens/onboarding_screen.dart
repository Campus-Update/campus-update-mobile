import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../shared/widgets/widgets.dart';

/// First run only.
///
/// The design is a single photograph carved into three joined pieces: a tall
/// panel, a narrow bridge carrying the page marks, and a pill at the foot that
/// the primary button sits inside. The carve is white page showing through, so
/// the whole thing is one image behind one clip path — see [_CarveClipper].
///
/// Every measurement below was taken off the design export and is expressed in
/// logical pixels at its 393pt frame width.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const _photo = 'assets/images/onboarding.png';

  /// Recorded on the way out, so onboarding is shown once and never again.
  Future<void> _leaveTo(
    BuildContext context,
    WidgetRef ref,
    String route,
  ) async {
    await ref.read(prefsStorageProvider).setOnboardingSeen(true);
    if (context.mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The page is white to the top edge, so the status bar needs dark icons.
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _CarveMetrics.gutter,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: _CarvedPhoto(
                    photo: _photo,
                    button: AppButton(
                      label: 'Get Started',
                      trailingIcon: Icons.chevron_right,
                      onPressed: () => _leaveTo(context, ref, Routes.register),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Wrap rather than Row: at a large text scale the line runs
                // wider than the screen, and Wrap drops "Login" to the next
                // line instead of overflowing.
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an Account? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.graphite,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _leaveTo(context, ref, Routes.login),
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'Login',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.indigo,
                          fontWeight: AppFonts.medium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The carve, measured off the design at a 393pt frame width.
///
/// All vertical figures are distances up from the bottom of the photo, because
/// the carve is anchored to the foot of the image while the panel above it
/// takes whatever height the screen has left.
abstract final class _CarveMetrics {
  /// Page gutter. Tighter than [AppSpacing.gutter]; the design runs the
  /// photograph almost to the screen edges.
  static const gutter = 8.0;

  /// The tall panel. Its bottom corners are drawn a touch rounder than its
  /// top ones — measured, not assumed.
  static const panelRadiusTop = 22.0;
  static const panelRadiusBottom = 28.0;

  /// The pill at the foot, which the button sits inside.
  static const footHeight = 76.0;
  static const footInset = 12.0;

  /// The white gap between panel and foot.
  static const carveHeight = 27.0;

  /// The bridge of photograph crossing that gap, at its narrowest. The gap is
  /// cut by two pills, so the bridge flares out by [carveHeight] where it
  /// meets the panel above and the foot below.
  static const bridgeWaist = 106.0;

  /// The three page marks, which fill the gap exactly top to bottom.
  static const markWidth = 7.0;
  static const markHeight = carveHeight;
  static const markGap = 28.0;
  static const markCount = 3;

  /// Where the button sits inside the foot, leaving a ring of photograph
  /// visible around it. These frame the button's full box — gradient plus its
  /// pale ring — which is why the inset is not the one the gradient alone
  /// would need.
  static const buttonInset = 16.0;
  static const buttonBottom = 10.0;
}

class _CarvedPhoto extends StatelessWidget {
  const _CarvedPhoto({required this.photo, required this.button});

  final String photo;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: const _CarveClipper(),
          child: Image.asset(
            photo,
            fit: BoxFit.cover,
            // Until the export is in place, show a flat brand ground rather
            // than Flutter's missing-asset box.
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: AppColors.indigoSurface),
          ),
        ),
        const Positioned.fill(child: _PageMarks()),
        Positioned(
          left: _CarveMetrics.buttonInset,
          right: _CarveMetrics.buttonInset,
          bottom: _CarveMetrics.buttonBottom,
          child: button,
        ),
      ],
    );
  }
}

/// Cuts the photograph into the design's three joined pieces: the tall panel,
/// the bridge, and the pill at the foot. What it removes is the white page
/// behind, which is what gives the carved look.
class _CarveClipper extends CustomClipper<Path> {
  const _CarveClipper();

  @override
  Path getClip(Size size) {
    final carveBottom = size.height - _CarveMetrics.footHeight;
    final carveTop = carveBottom - _CarveMetrics.carveHeight;
    const capRadius = _CarveMetrics.carveHeight / 2;
    final centre = size.width / 2;

    // The card, solid across the gap for now.
    final solid = Path()
      ..addRRect(
        RRect.fromLTRBAndCorners(
          0,
          0,
          size.width,
          carveTop,
          topLeft: const Radius.circular(_CarveMetrics.panelRadiusTop),
          topRight: const Radius.circular(_CarveMetrics.panelRadiusTop),
          bottomLeft: const Radius.circular(_CarveMetrics.panelRadiusBottom),
          bottomRight: const Radius.circular(_CarveMetrics.panelRadiusBottom),
        ),
      )
      ..addRect(Rect.fromLTRB(0, carveTop, size.width, carveBottom))
      ..addRRect(
        RRect.fromLTRBR(
          _CarveMetrics.footInset,
          carveBottom,
          size.width - _CarveMetrics.footInset,
          size.height,
          const Radius.circular(_CarveMetrics.footHeight / 2),
        ),
      );

    // Two pills taken out of the gap, one from each side. Their round caps
    // are what give the bridge its waist and the panel and foot their flare;
    // a plain rectangle here leaves square corners the design does not have.
    // They overhang the card so their outer caps fall outside it.
    const overhang = _CarveMetrics.carveHeight;
    final cuts = Path()
      ..addRRect(
        RRect.fromLTRBR(
          -overhang,
          carveTop,
          centre - _CarveMetrics.bridgeWaist / 2,
          carveBottom,
          const Radius.circular(capRadius),
        ),
      )
      ..addRRect(
        RRect.fromLTRBR(
          centre + _CarveMetrics.bridgeWaist / 2,
          carveTop,
          size.width + overhang,
          carveBottom,
          const Radius.circular(capRadius),
        ),
      );

    return Path.combine(PathOperation.difference, solid, cuts);
  }

  @override
  bool shouldReclip(_CarveClipper oldClipper) => false;
}

/// The three marks sitting on the bridge. They fill the gap exactly, top to
/// bottom, which is what sets their height.
class _PageMarks extends StatelessWidget {
  const _PageMarks();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: _CarveMetrics.footHeight),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _CarveMetrics.markCount; i++) ...[
              if (i > 0)
                const SizedBox(
                  width: _CarveMetrics.markGap - _CarveMetrics.markWidth,
                ),
              Container(
                width: _CarveMetrics.markWidth,
                height: _CarveMetrics.markHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    _CarveMetrics.markWidth / 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
