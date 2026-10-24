import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A checkbox with its label, as the design draws it: a small rounded square
/// filled flat grey when off, with the whole row tappable.
///
/// Figures measured off the design at its 393pt frame width.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;

  static const _size = 16.0;
  static const _radius = 4.0;
  static const _gap = 7.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onChanged != null;

    return GestureDetector(
      onTap: enabled ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        checked: value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                // The design only draws the unticked state; the ticked one
                // follows the palette and should be confirmed.
                color: value ? AppColors.indigo : AppColors.checkboxOff,
                borderRadius: BorderRadius.circular(_radius),
              ),
              child: value
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: _gap),
            // Flexible so a long label or a large text scale shortens the
            // text rather than overflowing the row it sits in.
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.graphite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
