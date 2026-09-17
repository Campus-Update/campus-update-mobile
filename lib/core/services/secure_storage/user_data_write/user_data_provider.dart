import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../secure_storage.dart';
import 'user_data_notifier.dart';
import 'user_data_state.dart';

final userDataProvider =
    StateNotifierProvider<UserDataNotifier, UserDataState>((ref) {
  final secureStorageService = ref.read(secureStorageProvider);
  return UserDataNotifier(secureStorageService);
});