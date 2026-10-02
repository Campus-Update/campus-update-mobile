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

  /// The deployed development API. Running the backend on your own machine
  /// instead needs a different host: `10.0.2.2` from the Android emulator, or
  /// `adb reverse tcp:5124 tcp:5124` and `localhost` from a real phone, which
  /// cannot see the laptop's loopback on its own.
  static const _devUrl = 'https://campus-update-api.vercel.app';

  // Neither exists yet; placeholders until there is somewhere to point them.
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
