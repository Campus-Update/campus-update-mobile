import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../constant.dart';
import '../secure_storage.dart';
import 'user_data_state.dart';

class UserDataNotifier extends StateNotifier<UserDataState> {
  final SecureStorageService _secureStorageService;

  UserDataNotifier(this._secureStorageService)
      : super(UserDataState.initial()) {
    initUserData();
  }

  Future<void> initUserData() async {
    final fields = [
      secure_storage_key.userId,
      secure_storage_key.first_name,
      secure_storage_key.last_name,
      secure_storage_key.username,
      secure_storage_key.email,
      secure_storage_key.role,
     
      secure_storage_key.is_verified,
    ];

    final userData = <String, String>{};

    for (var field in fields) {
      final value = await _secureStorageService.read(field);
      if (value != null) {
        userData[field] = value;
      }
    }

    state = state.copyWith(userData);
  }

  Future<void> updateField(String key, String value) async {
    await _secureStorageService.write(key, value);
    state = state.copyWith({key: value});
  }

  Future<void> deleteField(String key) async {
    await _secureStorageService.delete(key);
    state = state.remove(key);
  }

  Future<void> clearUserData() async {
    for (var key in state.data.keys) {
      await _secureStorageService.delete(key);
    }
    state = UserDataState.initial();
  }
}