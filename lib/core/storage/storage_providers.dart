import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_storage.dart';
import 'secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>(
  (ref) => const SecureStorage(FlutterSecureStorage()),
);

/// Overridden in main() once SharedPreferences has loaded, so the rest of the
/// app can read preferences synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final prefsStorageProvider = Provider<PrefsStorage>(
  (ref) => PrefsStorage(ref.watch(sharedPreferencesProvider)),
);
