import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';

/// The shell the know-your-user questions share: the step bar, the back
/// button, the question and its explanation, then whatever the step asks,
/// with its buttons pinned to the foot.
///
/// The questions come after the account exists, so the buttons stay in view
/// rather than scrolling away with a long list of institutions.
class KyuPage extends StatelessWidget {
  const KyuPage({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.footer,
  });

  /// Which of [steps] this is, counting from one.
  final int step;

  final String title;
  final String subtitle;

  /// The body of the question.
  final Widget body;

  /// The buttons, held at the foot of the screen.
  final Widget footer;

  /// School, then student or staff, then where you sit.
  static const steps = 3;

  static const _gutter = AppFormPanel.gutter;
  static const _toBack = 16.0;
  static const _toTitle = 24.0;
  static const _toSubtitle = 8.0;
  static const _toBody = 24.0;
  static const _toFooter = 16.0;
  static const _bottom = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _toBack),
                  const BackButtonCircle(),
                  const SizedBox(height: _toBack),
                  Center(
                    child: StepProgress(steps: steps, current: step),
                  ),
                  const SizedBox(height: _toTitle),
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: _toSubtitle),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: _toBody),
                  Expanded(child: body),
                  const SizedBox(height: _toFooter),
                  footer,
                  const SizedBox(height: _bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
