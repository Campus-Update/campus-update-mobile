import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';

/// How the entered code is being judged.
enum OtpStatus { neutral, correct, wrong }

/// The six-box code entry.
///
/// Behind the boxes sits a single invisible field rather than six separate
/// ones. That is what makes paste work, lets backspace walk back through the
/// digits, and — with [AutofillHints.oneTimeCode] — lets the platform offer
/// the code straight from the message it arrived in. Six fields would give up
/// all three.
///
/// Figures measured off the design at its 393pt frame width.
class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.label,
    this.length = 6,
    this.helper,
    this.status = OtpStatus.neutral,
    this.onChanged,
    this.onCompleted,
    this.autofocus = true,
  });

  final String label;
  final int length;

  /// Sits under the boxes and takes the status colour — the design swaps it
  /// for "OTP Correct" or "Wrong OTP".
  final String? helper;

  final OtpStatus status;
  final ValueChanged<String>? onChanged;

  /// Fired once the last box is filled, so callers need not watch the length.
  final ValueChanged<String>? onCompleted;

  final bool autofocus;

  static const boxHeight = 48.0;
  static const boxRadius = 10.0;
  static const boxGap = 10.0;
  static const labelGap = 10.0;
  static const helperGap = 10.0;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onEdit);
  }

  @override
  void dispose() {
    _controller.removeListener(_onEdit);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onEdit() {
    setState(() {});
    final value = _controller.text;
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  Color _borderColor(bool filled) => switch (widget.status) {
    OtpStatus.correct => AppColors.otpCorrect,
    OtpStatus.wrong => AppColors.otpWrong,
    OtpStatus.neutral => AppColors.otpBorder,
  };

  /// The message stays grey whatever the verdict — only the boxes change
  /// colour. Confirmed against the design's own "OTP Correct" and
  /// "Wrong OTP" text, both #555555.
  Color get _helperColor => AppColors.fieldLabel;

  /// The instruction is set a point smaller than the verdict that replaces
  /// it. Measured: the instruction's line is 299 wide in the design, which is
  /// 11, while both verdicts are specified at 12.
  double get _helperSize => widget.status == OtpStatus.neutral ? 11 : 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = _controller.text;

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
        const SizedBox(height: OtpField.labelGap),
        Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: OtpField.boxGap),
                  Expanded(
                    child: _Box(
                      character: i < value.length ? value[i] : '',
                      borderColor: _borderColor(i < value.length),
                    ),
                  ),
                ],
              ],
            ),
            // The real field, invisible and laid over the boxes so a tap
            // anywhere in the row opens the keyboard.
            Positioned.fill(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                showCursor: false,
                enableInteractiveSelection: false,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: OtpField.helperGap),
          Text(
            widget.helper!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: _helperSize,
              color: _helperColor,
            ),
          ),
        ],
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.character, required this.borderColor});

  final String character;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: OtpField.boxHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(OtpField.boxRadius),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        character,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: AppColors.graphite),
      ),
    );
  }
}
