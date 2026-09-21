import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A muted sentence with tappable words inside it.
///
/// Covers every variation the auth flow uses — "Already have an Account?
/// **Login**", "Didn't receive any code? **Resend**", and the terms footnote
/// with two links in one sentence — because the links are matched by their
/// text rather than passed as separate widgets:
///
/// ```dart
/// AppLinkText(
///   'Already have an Account? Login',
///   links: {'Login': () => context.go(Routes.login)},
/// )
/// ```
///
/// A [TapGestureRecognizer] has to be disposed, which is why this is
/// stateful; building them inline in a screen's `build` leaks them.
class AppLinkText extends StatefulWidget {
  const AppLinkText(
    this.text, {
    super.key,
    required this.links,
    this.textAlign = TextAlign.center,
    this.underline = false,
    this.style,
  });

  final String text;

  /// Word or phrase from [text] mapped to what tapping it does. Each key must
  /// appear in [text]; anything that does not match is drawn as plain text.
  final Map<String, VoidCallback> links;

  final TextAlign textAlign;

  /// The design underlines "Forgot Password?" but not "Login".
  final bool underline;

  /// Defaults to the muted body style the design uses under forms.
  final TextStyle? style;

  @override
  State<AppLinkText> createState() => _AppLinkTextState();
}

class _AppLinkTextState extends State<AppLinkText> {
  /// One recognizer per link, made once and reused. Building them in [build]
  /// instead would create a fresh set on every frame.
  late Map<String, TapGestureRecognizer> _recognizers = _build();

  Map<String, TapGestureRecognizer> _build() => {
    for (final entry in widget.links.entries)
      entry.key: TapGestureRecognizer()..onTap = entry.value,
  };

  @override
  void didUpdateWidget(AppLinkText old) {
    super.didUpdateWidget(old);
    if (old.links.keys.join('\u0000') != widget.links.keys.join('\u0000')) {
      _dispose();
      _recognizers = _build();
    } else {
      // Same links, possibly new closures.
      for (final entry in widget.links.entries) {
        _recognizers[entry.key]?.onTap = entry.value;
      }
    }
  }

  void _dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  /// Splits the sentence on whichever link comes next, so the links may
  /// appear in any order and more than one may share a sentence.
  List<TextSpan> _spans(TextStyle linkStyle) {
    final spans = <TextSpan>[];
    var rest = widget.text;

    while (rest.isNotEmpty) {
      var at = -1;
      String? hit;
      for (final key in widget.links.keys) {
        final i = rest.indexOf(key);
        if (i != -1 && (at == -1 || i < at)) {
          at = i;
          hit = key;
        }
      }
      if (hit == null) {
        spans.add(TextSpan(text: rest));
        break;
      }
      if (at > 0) spans.add(TextSpan(text: rest.substring(0, at)));

      spans.add(
        TextSpan(text: hit, style: linkStyle, recognizer: _recognizers[hit]),
      );
      rest = rest.substring(at + hit.length);
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base =
        widget.style ??
        theme.textTheme.labelMedium?.copyWith(color: AppColors.fieldLabel);

    final linkStyle = base?.copyWith(
      color: AppColors.link,
      decoration: widget.underline ? TextDecoration.underline : null,
      decorationColor: AppColors.link,
    );

    return Text.rich(
      TextSpan(children: _spans(linkStyle ?? const TextStyle())),
      textAlign: widget.textAlign,
      style: base,
    );
  }
}
