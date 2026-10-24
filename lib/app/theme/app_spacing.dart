/// The spacing scale. Use these instead of arbitrary numbers so padding stays
/// consistent across screens written by different people.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  /// Standard horizontal page gutter.
  static const gutter = md;

  /// Height of [ScreenHeader], fixed so titles optically centre.
  static const headerHeight = 52.0;

  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
}
