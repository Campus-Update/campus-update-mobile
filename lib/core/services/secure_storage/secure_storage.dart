import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constant.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String cachedToken = "";

  Future<void> write(String key, String value) async {
    log("<<<SecureStorageService>>>");
    log("write key: $key , value : $value");
    log('*********************');
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> delete(String key) async {
    log("<<<SecureStorageService>>>");
    log("delete key: $key");
    log('*********************');
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  Future<void> deleteMultiple(List<String> keys) async {
    for (var key in keys) { 
      log("<<$key>> deleted ");
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> initAuthTokenAndUserData() async {
    cachedToken =
        await _secureStorage.read(key: secure_storage_key.authToken) ?? "";
    if (cachedToken.isNotEmpty) {
      log("token: $cachedToken");
      await _initUserData();
    } else {
      log("no data cached");
    }
  }

  Future<void> _initUserData() async {
    final fields = [
      secure_storage_key.userId,
      secure_storage_key.first_name,
      secure_storage_key.last_name,
      secure_storage_key.username,
      secure_storage_key.email,
      secure_storage_key.role,
      secure_storage_key.is_verified,
      secure_storage_key.phone_number,
    ];

    final userData = <String, String>{};

    for (var field in fields) {
      final value = await _secureStorage.read(key: field);
      if (value != null) {
        userData[field] = value;
      }
    }

    log("User data loaded: $userData");
  }

  String getCachedToken() {
    return cachedToken;
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});