import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart';

/// A client with no interceptors, for calls made before a session exists —
/// the school list, registering, signing in.
final bareDioProvider = Provider<Dio>((ref) => DioClient.bare());
