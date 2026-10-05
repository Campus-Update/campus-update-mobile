import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Which treatment the button takes.
///
/// [primary] is specified by design: a 50px gradient pill, fully rounded, with
/// 30px of horizontal padding. [secondary] is its Skip — the same pill in
/// white behind a hairline. [ghost] and [danger] still await their screens.
enum AppButtonVariant { primary, secondary, ghost, danger }

/// The button used across the app.
///
/// Sizing comes from the design system rather than the caller: fixed 50px
/// height, 100px radius, filling the width it is given. Pass [trailingIcon] for
/// the chevron on "Get Started", [leadingIcon] where a mark sits before the
/// label.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.expand = true,
    this.onImage = false,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Fill the available width, as the design's `Fill` layout does.
  final bool expand;

  /// Adds the pale ring the design draws when the button sits on a
  /// photograph, which is the only place it appears — on a white page the
  /// gradient meets the background directly. Onboarding uses it; the auth
  /// screens do not.
  final bool onImage;

  /// Overrides the label size. Leave it null and the button stays on
  /// [_labelStyle], which is what the design specifies; pass a size only for a
  /// button the design genuinely draws differently, so that the default stays
  /// the single source of truth rather than something each screen re-picks.
  final double? fontSize;

  /// Height of the gradient itself. The primary variant then carries
  /// [_ringWidth] of ring outside that, so its box is taller by twice it.
  static const _height = 50.0;
  static const _radius = 100.0;
  static const _paddingX = 30.0;

  /// The pale ring around the primary button, measured off the design.
  static const _ringWidth = 2.0;

  /// The label, straight off the design: Archivo Medium 14 on a 20 line box,
  /// no letter spacing. Not [TextTheme.titleMedium] — that is 16, which
  /// overruns a half-width button ("Add details" needs 82pt at 16 but only
  /// 71 at 14, and a side-by-side pair leaves 78pt on a 360pt phone).
  static const _labelStyle = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: AppFonts.medium,
  );

  bool get _ringed => onImage && variant == AppButtonVariant.primary;

  /// The ring sits outside the gradient, so a ringed button's box is taller
  /// than its specified 50 by twice the ring.
  double get _boxHeight => _ringed ? _height + _ringWidth * 2 : _height;

  bool get _enabled => onPressed != null && !loading;

  Color _foreground(ColorScheme scheme) => switch (variant) {
    AppButtonVariant.primary || AppButtonVariant.danger => Colors.white,
    AppButtonVariant.secondary => AppColors.graphite,
    AppButtonVariant.ghost => AppColors.indigo,
  };

  BoxDecoration _decoration(ColorScheme scheme) {
    final radius = BorderRadius.circular(_radius);
    return switch (variant) {
      AppButtonVariant.primary => BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: radius,
        // Drawn inside the box, which is why a ringed button's box is taller
        // than the gradient: the gradient keeps its specified 50.
        border: _ringed
            ? Border.all(color: AppColors.buttonRing, width: _ringWidth)
            : null,
      ),
      AppButtonVariant.danger => BoxDecoration(
        color: AppColors.alertRed,
        borderRadius: radius,
      ),
      // The design's Skip: white, with a hairline the same grey a field
      // carries, so it reads as the quieter of a pair.
      AppButtonVariant.secondary => BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(color: AppColors.fieldBorder),
      ),
      AppButtonVariant.ghost => BoxDecoration(borderRadius: radius),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = _foreground(scheme);

    final content = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: foreground),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: _labelStyle.copyWith(
                    color: foreground,
                    fontSize: fontSize,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(trailingIcon, size: 18, color: foreground),
              ],
            ],
          );

    return Opacity(
      opacity: _enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(_radius),
          child: Ink(
            height: _boxHeight,
            width: expand ? double.infinity : null,
            decoration: _decoration(scheme),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _paddingX),
              child: Center(widthFactor: expand ? null : 1, child: content),
            ),
          ),
        ),
      ),
    );
  }
}
