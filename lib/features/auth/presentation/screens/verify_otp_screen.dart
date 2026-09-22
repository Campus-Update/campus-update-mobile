import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_page.dart';

/// Sits between Create Account and the academic questions.
///
/// The same screen serves the password reset flow, which sends its code to a
/// named address — hence [email] and the overridable copy.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({
    super.key,
    this.title = 'Verify OTP',
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
    // Where a verified code leads is the opener's business, not this
    // screen's — registration and password reset go to different places.
    widget.onVerified?.call(code);
  }

  void _resend() {}

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
        const SizedBox(height: AuthGaps.toLink),
        AppLinkText(
          "Didn't receive any code? Resend",
          links: {'Resend': _resend},
        ),
      ],
    );
  }
}

/// What the opener hands the screen: whose code this is, what to call it, and
/// where a correct one leads.
class OtpArgs {
  const OtpArgs({required this.title, required this.next, this.email});

  final String title;

  /// Route pushed once six digits are entered.
  final String next;

  final String? email;
}
