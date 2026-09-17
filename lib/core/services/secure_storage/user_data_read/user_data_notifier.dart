import 'package:campus_update/core/services/secure_storage/secure_storage.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../models/student.dart';
import '../constant.dart';

class UserDataNotifier extends StateNotifier<Student?> {
  final SecureStorageService _secureStorageService;

  UserDataNotifier(this._secureStorageService) : super(null);

  Future<void> loadUserData() async {
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

    final userDataMap = <String, String>{};

    for (var field in fields) {
      final value = await _secureStorageService.read(field);
      if (value != null) {
        userDataMap[field] = value;
      }
    }

    if (userDataMap.isNotEmpty) {
      state = Student(
        firstName: userDataMap[secure_storage_key.first_name] ?? "",
        lastName: userDataMap[secure_storage_key.last_name] ?? "",
        username: userDataMap[secure_storage_key.username] ?? "",
        email: userDataMap[secure_storage_key.email] ?? "",
        role: userDataMap[secure_storage_key.role] ?? "",

        phone_number: userDataMap[secure_storage_key.phone_number] ?? "",
        id: 111,
      );
    }
  }

  void resetState() {
    state = null;
  }
}

final userDataReaderProvider =
    StateNotifierProvider<UserDataNotifier, Student?>((ref) {
      final secureStorageService = ref.read(secureStorageProvider);
      return UserDataNotifier(secureStorageService);
    });
