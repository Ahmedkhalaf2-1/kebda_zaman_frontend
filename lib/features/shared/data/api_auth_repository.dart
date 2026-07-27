import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;
  final TokenStorage tokenStorage;

  ApiAuthRepository({
    required this.apiClient,
    required this.secureStorage,
    required this.tokenStorage,
  });

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    tokenStorage.accessToken = accessToken;
    await secureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> _clearTokens() async {
    tokenStorage.accessToken = null;
    await secureStorage.delete(key: 'refreshToken');
  }

  Result<User> _handleAuthResult(Response response) {
    try {
      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user']);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      _saveTokens(accessToken, refreshToken);
      return Success(user);
    } catch (e) {
      return const Err(AuthFailure('Failed to parse user data'));
    }
  }

  Failure _handleError(dynamic e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (e.error is ApiException) {
        final apiException = e.error as ApiException;
        // Only genuine auth rejections (invalid/expired/missing credentials) should be
        // treated as AuthFailure — a transient network/server error must not be conflated
        // with "the session is invalid" (see auth_notifier._loadSavedUser, which logs the
        // user out on AuthFailure but preserves the session on NetworkFailure).
        if (statusCode == 401 || statusCode == 403) {
          return AuthFailure(apiException.message);
        }
        return NetworkFailure(apiException.message);
      }
      return NetworkFailure(e.message ?? 'Network error');
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _handleAuthResult(response);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<User>> adminLogin(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/admin/auth/login',
        data: {'email': email, 'password': password},
      );
      return _handleAuthResult(response);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
      return _handleAuthResult(response);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<User>> guestLogin() async {
    try {
      final response = await apiClient.dio.post('/auth/guest', data: {});
      return _handleAuthResult(response);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final refreshToken = await secureStorage.read(key: 'refreshToken');
      await apiClient.dio.post(
        '/auth/logout',
        data: {if (refreshToken != null) 'refreshToken': refreshToken},
      );
    } catch (e) {
      // Even if backend fails, clear locally
    } finally {
      await _clearTokens();
    }
    return const Success(null);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get('/users/me');
      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data);
      return Success(user);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      if (locale != null) data['locale'] = locale;

      final response = await apiClient.dio.patch('/users/me', data: data);
      final responseData = response.data as Map<String, dynamic>;
      final user = User.fromJson(responseData);
      return Success(user);
    } catch (e) {
      return Err(_handleError(e));
    }
  }
}
