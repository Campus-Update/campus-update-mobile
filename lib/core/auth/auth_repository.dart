import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_exception.dart';
import '../network/network_providers.dart';
import '../storage/secure_storage.dart';
import '../storage/storage_providers.dart';

/// What `POST /auth/login` and `POST /auth/register` both return.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    userId: json['userId'] as String,
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresAt:
        DateTime.tryParse(json['expiresAt'] as String? ?? '') ?? DateTime.now(),
  );

  final String userId;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
}

/// Which audience a person belongs to.
///
/// Sent as a string. The spec types `UserRole` as an integer, but the API
/// reads and writes `"Student"` and `"Staff"` — confirmed against the
/// deployed service, and raised with the backend.
enum UserRole {
  student('Student'),
  staff('Staff');

  const UserRole(this.wireName);

  final String wireName;
}

/// Everything `POST /auth/register` insists on, in one object.
///
/// It is gathered across four screens but sent once, so it travels as a value
/// rather than as arguments threaded through navigation.
class RegistrationRequest {
  const RegistrationRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.institutionId,
    this.facultyId,
    this.departmentId,
    this.programmeId,
    this.academicLevelId,
    this.matriculationOrStaffNumber,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String institutionId;
  final String? facultyId;
  final String? departmentId;
  final String? programmeId;
  final String? academicLevelId;
  final String? matriculationOrStaffNumber;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'role': role.wireName,
    'institutionId': institutionId,
    'facultyId': facultyId,
    'departmentId': departmentId,
    'programmeId': programmeId,
    'academicLevelId': academicLevelId,
    'matriculationOrStaffNumber': matriculationOrStaffNumber,
  };
}

/// Signing in, registering, and signing out.
///
/// Uses the interceptor-free client: none of these calls carries a token, and
/// a 401 from signing in means wrong credentials rather than an expired
/// session to refresh.
class AuthRepository {
  const AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final SecureStorage _storage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) => _post('/api/v1/auth/login', {'email': email, 'password': password});

  Future<AuthSession> register(RegistrationRequest request) =>
      _post('/api/v1/auth/register', request.toJson());

  Future<void> signOut() => _storage.clear();

  Future<AuthSession> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(path, data: body);
      final data = res.data;
      if (data == null) {
        throw const ApiException(
          statusCode: null,
          message: 'The server returned nothing. Please try again.',
        );
      }
      final session = AuthSession.fromJson(data);
      await _storage.writeTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      return session;
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(bareDioProvider),
    ref.watch(secureStorageProvider),
  ),
);
