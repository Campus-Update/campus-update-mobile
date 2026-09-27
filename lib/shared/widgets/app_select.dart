import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'app_input.dart';

/// A labelled dropdown, drawn as the text field is: the same white box, the
/// same hairline and radius, with a chevron where a field would carry its
/// icon.
class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.hint,
    this.onChanged,
    this.labelOf,
  });

  final String label;
  final List<T> options;
  final T? value;
  final String? hint;
  final ValueChanged<T?>? onChanged;

  /// How to name an option; defaults to its `toString`.
  final String Function(T)? labelOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onChanged != null && options.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.fieldLabel,
          ),
        ),
        const SizedBox(height: AppInput.labelGap),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          hint: hint == null
              ? null
              : Text(hint!, style: theme.inputDecorationTheme.hintStyle),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.fieldLabel,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(height: 1),
          items: [
            for (final o in options)
              DropdownMenuItem(
                value: o,
                child: Text(labelOf?.call(o) ?? o.toString()),
              ),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
