import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The segmented bar across the top of the know-your-user questions.
///
/// Segments share the width evenly, so the design's 299 across four segments
/// with a 10 gap comes out at its 67.25 each without hard-coding it.
///
/// Figures measured off the design at its 393pt frame width.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.steps, required this.current});

  /// How many segments to draw.
  final int steps;

  /// How many are filled, counting from the left.
  final int current;

  static const width = 299.0;
  static const height = 5.0;
  static const gap = 10.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        // Stretch, or a childless DecoratedBox takes the Row's loose
        // vertical constraint and collapses to nothing.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < steps; i++) ...[
            if (i > 0) const SizedBox(width: gap),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // Filled takes the brand indigo, the rest its palest step.
                  // Sampled rather than specified — confirm against the ramp.
                  color: i < current
                      ? AppColors.indigo
                      : AppColors.indigoSurface,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
