import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';

/// Which provider the button signs in with.
enum SocialProvider {
  google(asset: 'assets/icons/google.svg', width: 15.68, height: 16);

  const SocialProvider({
    required this.asset,
    required this.width,
    required this.height,
  });

  final String asset;

  /// The mark's own proportions, from the design. Google's is not square.
  final double width;
  final double height;
}

/// The dark pill used for social sign-in.
///
/// Shares the primary button's height but not its shape — the design gives
/// this a 32 radius against the primary's fully rounded pill.
///
/// Figures measured off the design at its 393pt frame width.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.provider = SocialProvider.google,
  });

  final String label;
  final VoidCallback? onPressed;
  final SocialProvider provider;

  static const _height = 50.0;
  static const _radius = 32.0;
  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_radius),
          child: Ink(
            height: _height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.socialGradient,
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  provider.asset,
                  width: provider.width,
                  height: provider.height,
                ),
                const SizedBox(width: _gap),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
