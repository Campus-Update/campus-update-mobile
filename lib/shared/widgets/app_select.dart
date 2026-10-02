import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'app_input.dart';

/// A labelled picker that looks like a text field and opens a sheet.
///
/// The field itself is drawn exactly as [AppInput] draws one — same white
/// box, hairline and radius — so a form of fields and pickers reads as one
/// thing. Choosing happens in a sheet from the bottom rather than a menu
/// pinned to the field, which is what a phone does.
///
/// The sheet's own styling is not in the design yet; it follows the form
/// panel and option rows so it at least belongs to the same family.
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

  static const _height = 48.0;
  static const _radius = 10.0;
  static const _padX = 17.0;

  bool get _enabled => onChanged != null && options.isNotEmpty;

  String _nameOf(T option) => labelOf?.call(option) ?? option.toString();

  Future<void> _pick(BuildContext context) async {
    final chosen = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _Sheet<T>(
        title: label,
        options: options,
        selected: value,
        nameOf: _nameOf,
      ),
    );
    if (chosen != null) onChanged?.call(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chosen = value;

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
        Opacity(
          opacity: _enabled ? 1 : 0.6,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_radius),
            child: InkWell(
              onTap: _enabled ? () => _pick(context) : null,
              borderRadius: BorderRadius.circular(_radius),
              child: Container(
                height: _height,
                padding: const EdgeInsets.symmetric(horizontal: _padX),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chosen == null ? (hint ?? '') : _nameOf(chosen),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1,
                          color: chosen == null
                              ? AppColors.fieldHint
                              : AppColors.graphite,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 22,
                      color: AppColors.fieldLabel,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Sheet<T> extends StatelessWidget {
  const _Sheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.nameOf,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T) nameOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ConstrainedBox(
        // Tall lists scroll rather than pushing the sheet off the screen.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final option = options[i];
                  final isSelected = option == selected;
                  return ListTile(
                    title: Text(
                      nameOf(option),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppColors.indigo
                            : AppColors.graphite,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 20,
                            color: AppColors.indigo,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
