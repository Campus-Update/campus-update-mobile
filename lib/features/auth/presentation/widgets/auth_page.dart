import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/widgets.dart';

/// The vertical rhythm every auth screen shares, measured off the design's
/// Sign in and Create Account frames. Both gave the same figures, so they are
/// the flow's rhythm rather than one screen's.
abstract final class AuthGaps {
  /// Safe area to the title, on a screen with no back button.
  static const top = 60.0;

  /// Safe area to the back button, and from it to the title.
  static const backTop = 16.0;
  static const backGap = 24.0;

  /// Title block to the form panel.
  static const toPanel = 28.0;

  /// Panel to the primary button.
  static const toButton = 28.0;

  /// Button to the line of link text under it.
  static const toLink = 10.0;

  /// Link to the "Or login with" rule.
  static const toDivider = 22.0;

  /// Rule to the social button.
  static const toSocial = 20.0;

  /// Social button to the terms footnote.
  static const toTerms = 12.0;

  /// Breathing room under the last element.
  static const bottom = 24.0;
}

/// The shell every auth screen sits in: a white page with the centred title
/// block at the top and whatever the screen needs below it.
///
/// Scrolls, because the keyboard takes roughly half the screen and these
/// forms are tall enough to be covered by it.
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingGap = 0,
    required this.children,
    this.subtitleMaxLines = 1,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;

  /// Sits centred above the title — the illustration some screens open with.
  final Widget? leading;

  /// Space between [leading] and the title.
  final double leadingGap;

  /// The back button appears wherever there is somewhere to go back to. Set
  /// false on a screen that must not be left by going back — a flow that has
  /// already changed something behind it.
  final bool showBack;

  /// Laid out below the title block, spaced by the caller using [AuthGaps].
  final List<Widget> children;

  /// Maximum number of lines for subtitle text in ScreenTitle.
  final int? subtitleMaxLines;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // A white page needs dark status bar icons.
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            // Tapping anywhere off a field puts the keyboard away. Opaque so
            // taps landing on blank page are caught; fields and buttons are
            // below this in the tree and still get theirs first.
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppFormPanel.gutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBack) ...[
                    const SizedBox(height: AuthGaps.backTop),
                    // Left-aligned in a stretched column, so it needs its own
                    // alignment rather than taking the full width.
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackButtonCircle(),
                    ),
                  ],
                  SizedBox(height: showBack ? AuthGaps.backGap : AuthGaps.top),
                  if (leading != null) ...[
                    Center(child: leading),
                    SizedBox(height: leadingGap),
                  ],
                  ScreenTitle(
                    title: title,
                    subtitle: subtitle,
                    maxLines: subtitleMaxLines,
                  ),
                  const SizedBox(height: AuthGaps.toPanel),
                  ...children,
                  const SizedBox(height: AuthGaps.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
