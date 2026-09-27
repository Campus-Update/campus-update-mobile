import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A pickable card: a title, a line under it, and a chevron.
///
/// The institution list and the student-or-staff cards are the same thing
/// with different content, so they are the same widget.
///
/// Figures measured off the design at its 393pt frame width.
class OptionRow extends StatelessWidget {
  const OptionRow({
    super.key,
    required this.title,
    this.subtitle,
    this.selected = false,
    this.onTap,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  /// The design leaves it off the one row that is already available and on
  /// the rest, which looks like an oversight; on by default.
  final bool showChevron;

  static const height = 74.0;
  static const radius = 10.0;
  static const gap = 16.0;
  static const _padLeft = 26.0;
  static const _padRight = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = selected ? Colors.white : AppColors.graphite;

    return Material(
      color: selected ? AppColors.optionSelected : AppColors.optionRest,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.only(left: _padLeft, right: _padRight),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColors.fieldLabel,
                          ),
                        ),
                    ],
                  ),
                ),
                if (showChevron)
                  Icon(Icons.chevron_right, size: 20, color: ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
