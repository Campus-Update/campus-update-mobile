import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token storage. Access and refresh tokens never touch shared preferences.
class SecureStorage {
  const SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessToken = 'access_token';
  static const _refreshToken = 'refresh_token';

  Future<String?> readAccessToken() => _storage.read(key: _accessToken);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshToken);

  /// The backend rotates the refresh token on every refresh, so both values are
  /// always written together — never one without the other.
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessToken, value: accessToken);
    await _storage.write(key: _refreshToken, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessToken);
    await _storage.delete(key: _refreshToken);
  }
}
