import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Which treatment the button takes.
///
/// [primary] is specified by design: a 50px gradient pill, fully rounded, with
/// 30px of horizontal padding. The others follow from the palette and should be
/// confirmed as their screens arrive.
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
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Fill the available width, as the design's `Fill` layout does.
  final bool expand;

  /// Height of the gradient itself. The primary variant then carries
  /// [_ringWidth] of ring outside that, so its box is taller by twice it.
  static const _height = 50.0;
  static const _radius = 100.0;
  static const _paddingX = 30.0;

  /// The pale ring around the primary button, measured off the design.
  static const _ringWidth = 2.0;

  /// The primary button's full box, gradient plus ring.
  double get _boxHeight =>
      variant == AppButtonVariant.primary ? _height + _ringWidth * 2 : _height;

  bool get _enabled => onPressed != null && !loading;

  Color _foreground(ColorScheme scheme) => switch (variant) {
    AppButtonVariant.primary || AppButtonVariant.danger => Colors.white,
    AppButtonVariant.secondary || AppButtonVariant.ghost => AppColors.indigo,
  };

  BoxDecoration _decoration(ColorScheme scheme) {
    final radius = BorderRadius.circular(_radius);
    return switch (variant) {
      AppButtonVariant.primary => BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: radius,
        // Drawn inside the box, which is why the box is taller than the
        // gradient by twice the ring: the gradient keeps its specified 50.
        border: Border.all(color: AppColors.buttonRing, width: _ringWidth),
      ),
      AppButtonVariant.danger => BoxDecoration(
        color: AppColors.alertRed,
        borderRadius: radius,
      ),
      AppButtonVariant.secondary => BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: AppColors.indigo),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: foreground),
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
