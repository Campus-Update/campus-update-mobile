import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_page.dart';

/// Sits between Create Account and the academic questions.
///
/// The same screen serves the password reset flow, which sends its code to a
/// named address — hence [email] and the overridable copy.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({
    super.key,
    this.title = 'Check Your Email',
    this.email,
    this.onVerified,
    this.autofocus = true,
  });

  final String title;

  /// Shown in the subtitle when the flow knows where the code went.
  final String? email;

  final ValueChanged<String>? onVerified;

  /// Off in tests, where an open keyboard obscures what is being checked.
  final bool autofocus;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  static const _illustration = 'assets/icons/envelope.svg';
  static const _illustrationWidth = 150.0;
  static const _illustrationHeight = 141.0;
  static const _toTitle = 16.0;

  OtpStatus _status = OtpStatus.neutral;

  String get _helper => switch (_status) {
    OtpStatus.correct => 'OTP Correct',
    OtpStatus.wrong => 'Wrong OTP',
    OtpStatus.neutral =>
      'We have sent a 6 digit code to your mail. Enter the code.',
  };

  void _onCompleted(String code) {
    widget.onVerified?.call(code);
    context.push(Routes.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: widget.title,
      subtitle: widget.email == null
          ? null
          : "We've sent a 6-digit verification code to ${widget.email}",
      subtitleMaxLines: 2,
      leading: SvgPicture.asset(
        _illustration,
        width: _illustrationWidth,
        height: _illustrationHeight,
      ),
      leadingGap: _toTitle,
      children: [
        AppFormPanel(
          children: [
            OtpField(
              label: 'OTP',
              autofocus: widget.autofocus,
              helper: _helper,
              status: _status,
              onChanged: (_) {
                if (_status != OtpStatus.neutral) {
                  setState(() => _status = OtpStatus.neutral);
                }
              },
              onCompleted: _onCompleted,
            ),
          ],
        ),
      ],
    );
  }
}
