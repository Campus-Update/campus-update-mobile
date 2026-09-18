/// App environment.
///
/// To switch environments, change [_active] below — that is the only line you
/// need to touch. A build can still override it without editing code:
/// `flutter build apk --dart-define=API_BASE_URL=https://...`
enum Flavor { dev, staging, prod }

abstract final class Env {
  // ---------------------------------------------------------------------------
  // Change this one line to switch environment.
  static const Flavor _active = Flavor.dev;
  // ---------------------------------------------------------------------------

  /// `10.0.2.2` is how the Android emulator reaches the host machine. On a
  /// physical phone, replace it with the host's LAN address — the phone cannot
  /// see the laptop's localhost.
  static const _devUrl = 'http://10.0.2.2:5124';

  // Neither environment exists yet; both are placeholders until the backend is
  // deployed.
  static const _stagingUrl = 'https://staging.campusupdate.example/';
  static const _prodUrl = 'https://api.campusupdate.example/';

  static const Flavor flavor = bool.hasEnvironment('FLAVOR')
      ? _flavorFromDefine
      : _active;

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _urlFor,
  );

  static const String _urlFor = _active == Flavor.prod
      ? _prodUrl
      : _active == Flavor.staging
      ? _stagingUrl
      : _devUrl;

  static const _flavorName = String.fromEnvironment('FLAVOR');
  static const Flavor _flavorFromDefine = _flavorName == 'prod'
      ? Flavor.prod
      : _flavorName == 'staging'
      ? Flavor.staging
      : Flavor.dev;

  static bool get isDev => flavor == Flavor.dev;
}
