import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';

/// A labelled text field.
///
/// The label is a plain line of text above the box, not Material's floating
/// label — the design keeps it still and outside the field, so this does not
/// use `labelText` at all.
///
/// Pass [obscure] for a password and the eye toggle comes with it; the widget
/// owns that visibility state so call sites do not have to.
///
/// Figures measured off the design at its 393pt frame width.
class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;

  /// Renders as a password: text is hidden and an eye toggle appears.
  final bool obscure;

  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;

  /// Let the platform offer saved credentials — worth setting on every auth
  /// field, or password managers cannot fill the form.
  final Iterable<String>? autofillHints;

  /// Gap between the label and the box below it.
  static const labelGap = 10.0;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  static const _eyeAsset = 'assets/icons/eye.svg';
  static const _eyeSize = 22.0;

  // A password's placeholder is drawn, not written: eight dots, 8 across,
  // 11 apart. Taken from the design's own SVG, which is why this cannot be
  // a hintText string.
  static const _dotCount = 8;
  static const _dotSize = 8.0;
  static const _dotPitch = 11.0;

  late bool _hidden = widget.obscure;

  /// Eight dots standing in for placeholder text on a password field.
  Widget _dotsHint() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _dotCount; i++) ...[
          if (i > 0) const SizedBox(width: _dotPitch - _dotSize),
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: const BoxDecoration(
              color: AppColors.fieldHintDot,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }

  /// The design supplies the eye as SVG; there is no crossed-out counterpart
  /// yet, so the revealed state falls back to the Material glyph. Swap it for
  /// the design's own when that arrives.
  Widget _revealToggle() {
    return IconButton(
      onPressed: () => setState(() => _hidden = !_hidden),
      tooltip: _hidden ? 'Show password' : 'Hide password',
      icon: _hidden
          ? SvgPicture.asset(
              _eyeAsset,
              width: _eyeSize,
              height: _eyeSize,
              colorFilter: const ColorFilter.mode(
                AppColors.fieldLabel,
                BlendMode.srcIn,
              ),
            )
          : const Icon(
              Icons.visibility_off_outlined,
              size: _eyeSize,
              color: AppColors.fieldLabel,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.fieldLabel,
          ),
        ),
        const SizedBox(height: AppInput.labelGap),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          // Line height 1 rather than the scale's 1.5: the field's height is
          // fixed at 48 by the design, and a 1.5 line pushes it to 55.
          style: theme.textTheme.bodyMedium?.copyWith(height: 1),
          decoration: InputDecoration(
            // A password's placeholder is the dot row; everything else uses
            // the caller's text.
            hint: widget.obscure ? _dotsHint() : null,
            hintText: widget.obscure ? null : widget.hint,
            // Keep the eye from forcing the field past 48 — IconButton wants
            // a 48 square of its own.
            suffixIconConstraints: const BoxConstraints(
              maxHeight: 44,
              maxWidth: 48,
            ),
            suffixIcon: widget.obscure ? _revealToggle() : null,
          ),
        ),
      ],
    );
  }
}
