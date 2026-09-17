import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dependency_injection/dependency_injection.dart';
import '../secure_storage/secure_storage.dart';


final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return getIt<SecureStorageService>();
});