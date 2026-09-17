import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import '../constant.dart';
import '../secure_storage.dart';

class AuthTokenNotifier extends StateNotifier<String> {
  final SecureStorageService _secureStorageService;

  AuthTokenNotifier(this._secureStorageService) : super('') {
    initToken();
  }

  Future<void> initToken() async {
    final token =
        await _secureStorageService.read(secure_storage_key.authToken);
    state = token ?? '';
  }

  Future<void> updateToken(String newToken) async {
    await _secureStorageService.write(secure_storage_key.authToken, newToken);
    state = newToken;
  }

  Future<void> deleteToken() async {
    await _secureStorageService.delete(secure_storage_key.authToken);
    state = '';
  }
}

final cachedAuthTokenProvider =
    StateNotifierProvider<AuthTokenNotifier, String>((ref) {
  final secureStorageService = ref.read(secureStorageProvider);
  return AuthTokenNotifier(secureStorageService);
});